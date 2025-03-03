#!/bin/bash

# Moodle on Azure Deployment Script
# This script automates the deployment of Moodle to Azure using Terraform

set -e

# Colors for console output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print decorated message
function print_message() {
  echo -e "${GREEN}=== $1 ===${NC}"
}

# Print warning message
function print_warning() {
  echo -e "${YELLOW}WARNING: $1${NC}"
}

# Print error message
function print_error() {
  echo -e "${RED}ERROR: $1${NC}"
}

# Check prerequisites
print_message "Checking prerequisites"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
  print_error "Terraform is not installed. Please install it and try again."
  exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
  print_error "Azure CLI is not installed. Please install it and try again."
  exit 1
fi

# Check if user is logged in to Azure
az account show &> /dev/null
if [ $? -ne 0 ]; then
  print_message "Logging in to Azure"
  az login
else
  print_message "Already logged in to Azure"
  az account show --query name -o tsv
fi

# Initialize Terraform
print_message "Initializing Terraform"
terraform init

# Check if terraform.tfvars exists, create it if not
if [ ! -f terraform.tfvars ]; then
  print_warning "terraform.tfvars not found. Creating from example file."
  
  if [ -f terraform.tfvars.example ]; then
    cp terraform.tfvars.example terraform.tfvars
    print_message "Please edit terraform.tfvars with your specific configuration values"
    print_message "After editing, run this script again"
    exit 0
  else
    print_error "terraform.tfvars.example not found. Please create a terraform.tfvars file manually."
    exit 1
  fi
fi

# Generate a plan
print_message "Generating Terraform plan"
terraform plan -out=moodle_plan

# Confirm with user before applying
echo ""
read -p "Do you want to apply this plan? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  print_warning "Deployment cancelled by user"
  exit 0
fi

# Apply the plan
print_message "Applying Terraform plan"
terraform apply "moodle_plan"

# Display outputs
print_message "Deployment completed"
echo ""
echo "Moodle URL:"
terraform output -raw moodle_url
echo ""
echo "To see all outputs, run: terraform output"
echo ""
print_message "Don't forget to complete the Moodle setup through the web interface"