#!/usr/bin/env bash

# Set these variables as needed
REGION="us-east-1"
PROFILE="shimbita-general"

# Step 1: Identify the default VPC
echo "Finding the default VPC in region $REGION under profile $PROFILE..."
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "Vpcs[0].VpcId" \
  --output text)

if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
  echo "No default VPC found in $REGION for profile $PROFILE."
  exit 0
fi

echo "Default VPC identified: $VPC_ID"

# Step 2: Delete subnets
echo "Deleting subnets associated with $VPC_ID..."
SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "Subnets[].SubnetId" \
  --output text)

if [ -n "$SUBNET_IDS" ]; then
  for SUBNET_ID in $SUBNET_IDS; do
    echo "Deleting subnet: $SUBNET_ID"
    aws ec2 delete-subnet \
      --subnet-id "$SUBNET_ID" \
      --region "$REGION" \
      --profile "$PROFILE"
  done
else
  echo "No subnets found for $VPC_ID."
fi

# Step 3: Detach and delete internet gateways
echo "Detaching and deleting Internet Gateways from $VPC_ID..."
IGW_IDS=$(aws ec2 describe-internet-gateways \
  --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --query "InternetGateways[].InternetGatewayId" \
  --output text)

if [ -n "$IGW_IDS" ]; then
  for IGW_ID in $IGW_IDS; do
    echo "Detaching IGW: $IGW_ID from VPC: $VPC_ID"
    aws ec2 detach-internet-gateway \
      --internet-gateway-id "$IGW_ID" \
      --vpc-id "$VPC_ID" \
      --region "$REGION" \
      --profile "$PROFILE"

    echo "Deleting IGW: $IGW_ID"
    aws ec2 delete-internet-gateway \
      --internet-gateway-id "$IGW_ID" \
      --region "$REGION" \
      --profile "$PROFILE"
  done
else
  echo "No Internet Gateways attached to $VPC_ID."
fi

# Step 4: Delete the default VPC
echo "Deleting the default VPC: $VPC_ID"
aws ec2 delete-vpc \
  --vpc-id "$VPC_ID" \
  --region "$REGION" \
  --profile "$PROFILE"

echo "Default VPC cleanup complete"
