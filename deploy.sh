#!/bin/bash

# deploy.sh - Script to deploy Moodle to Azure using Terraform
# This script applies the Terraform configuration and logs the results

# Set up logging
LOGFILE="moodle_deployment_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a $LOGFILE) 2>&1

echo "=========================================================="
echo "Starting Moodle Deployment to Azure using Terraform"
echo "Deployment time: $(date)"
echo "=========================================================="

# Check for Azure CLI
if ! command -v az &> /dev/null; then
    echo "Azure CLI not found. Please install it first."
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check for Terraform
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found. Please install it first."
    echo "Visit: https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
fi

# Check Azure login
echo "Checking Azure login..."
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo "Not logged in to Azure. Please login first."
    az login
fi

echo "Using Azure subscription:"
az account show --query name -o tsv

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate
if [ $? -ne 0 ]; then
    echo "Terraform validation failed. Please fix the errors and try again."
    exit 1
fi

# Create a plan
echo "Creating Terraform plan..."
terraform plan -out=moodle.tfplan

# Apply the plan
echo "Applying Terraform plan..."
terraform apply "moodle.tfplan"

if [ $? -eq 0 ]; then
    echo "Moodle deployment successful!"
    
    # Get the outputs
    echo "=========================================================="
    echo "Deployment Information:"
    echo "=========================================================="
    echo "Moodle URL: $(terraform output -raw moodle_url)"
    echo "Moodle Admin URL: $(terraform output -raw moodle_admin_url)"
    echo "Resource Group: $(terraform output -raw resource_group_name)"
    echo ""
    echo "Connection Instructions: $(terraform output -raw connection_instructions)"
    echo ""
    echo "Note: It may take a few minutes for Moodle to fully initialize after deployment."
    echo "=========================================================="
else
    echo "Moodle deployment failed. Check the logs for details."
    exit 1
fi

echo "Deployment details are saved in: $LOGFILE"