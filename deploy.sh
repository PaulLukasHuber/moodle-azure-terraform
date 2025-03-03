#!/bin/bash

# Moodle on Azure Deployment Script
# This script automates the deployment of Moodle to Azure using Terraform

# Initialize log file
LOG_FILE="moodle_deployment_$(date +%Y%m%d_%H%M%S).log"
echo "=== Moodle Deployment Log - Started at $(date) ===" > "$LOG_FILE"

set -e

# Colors for console output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print decorated message and log it
function log_message() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${GREEN}=== $1 ===${NC}"
  echo "[$timestamp] INFO: $1" >> "$LOG_FILE"
}

# Print and log warning message
function log_warning() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${YELLOW}WARNING: $1${NC}"
  echo "[$timestamp] WARNING: $1" >> "$LOG_FILE"
}

# Print and log error message
function log_error() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${RED}ERROR: $1${NC}"
  echo "[$timestamp] ERROR: $1" >> "$LOG_FILE"
}

# Execute command and log output
function execute_and_log() {
  local cmd="$1"
  local msg="$2"
  
  log_message "$msg"
  echo "[$timestamp] COMMAND: $cmd" >> "$LOG_FILE"
  
  # Execute the command, capture output and exit code
  output=$(eval "$cmd" 2>&1)
  exit_code=$?
  
  # Log the output
  echo "$output" | while read -r line; do
    echo "[$timestamp] OUTPUT: $line" >> "$LOG_FILE"
  done
  
  # Also print to console if verbose
  echo "$output"
  
  # Return the original exit code
  return $exit_code
}

# Check prerequisites
log_message "Checking prerequisites"

# Log system information
echo "[$(date +"%Y-%m-%d %H:%M:%S")] SYSTEM: $(uname -a)" >> "$LOG_FILE"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] DIRECTORY: $(pwd)" >> "$LOG_FILE"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
  log_error "Terraform is not installed. Please install it and try again."
  exit 1
fi

# Log terraform version
terraform_version=$(terraform version)
echo "[$(date +"%Y-%m-%d %H:%M:%S")] TERRAFORM: $terraform_version" >> "$LOG_FILE"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
  log_error "Azure CLI is not installed. Please install it and try again."
  exit 1
fi

# Log Azure CLI version
az_version=$(az version | jq -r ".[\"azure-cli\"]")
echo "[$(date +"%Y-%m-%d %H:%M:%S")] AZURE CLI: $az_version" >> "$LOG_FILE"

# Check if user is logged in to Azure
az account show &> /dev/null
if [ $? -ne 0 ]; then
  log_message "Logging in to Azure"
  az login 2>&1 | tee -a "$LOG_FILE"
else
  log_message "Already logged in to Azure"
  account_info=$(az account show --query name -o tsv)
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] AZURE ACCOUNT: $account_info" >> "$LOG_FILE"
  echo "$account_info"
fi

# Initialize Terraform
log_message "Initializing Terraform"
execute_and_log "terraform init" "Running terraform init"

# Check if terraform.tfvars exists, create it if not
if [ ! -f terraform.tfvars ]; then
  log_warning "terraform.tfvars not found. Creating from example file."
  
  if [ -f terraform.tfvars.example ]; then
    cp terraform.tfvars.example terraform.tfvars
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] ACTION: Created terraform.tfvars from example" >> "$LOG_FILE"
    log_message "Please edit terraform.tfvars with your specific configuration values"
    log_message "After editing, run this script again"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] INFO: Deployment paused for tfvars editing" >> "$LOG_FILE"
    exit 0
  else
    log_error "terraform.tfvars.example not found. Please create a terraform.tfvars file manually."
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] ERROR: terraform.tfvars.example not found" >> "$LOG_FILE"
    exit 1
  fi
fi

# Generate a plan
log_message "Generating Terraform plan"
execute_and_log "terraform plan -out=moodle_plan" "Creating deployment plan"

# Confirm with user before applying
echo ""
read -p "Do you want to apply this plan? (y/n) " -n 1 -r
echo ""
echo "[$(date +"%Y-%m-%d %H:%M:%S")] USER INPUT: Apply plan - $REPLY" >> "$LOG_FILE"

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  log_warning "Deployment cancelled by user"
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] ACTION: Deployment cancelled by user" >> "$LOG_FILE"
  exit 0
fi

# Apply the plan
log_message "Applying Terraform plan"
execute_and_log "terraform apply \"moodle_plan\"" "Deploying resources to Azure"

# Display outputs
log_message "Deployment completed"
echo ""
echo "Moodle URL:"
moodle_url=$(terraform output -raw moodle_url)
echo "$moodle_url"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] MOODLE URL: $moodle_url" >> "$LOG_FILE"

echo ""
echo "To see all outputs, run: terraform output"
echo ""
log_message "Don't forget to complete the Moodle setup through the web interface"

# Log completion
echo "[$(date +"%Y-%m-%d %H:%M:%S")] DEPLOYMENT SUMMARY:" >> "$LOG_FILE"
terraform output >> "$LOG_FILE"
echo "[$(date +"%Y-%m-%d %H:%M:%S")] DEPLOYMENT COMPLETED SUCCESSFULLY" >> "$LOG_FILE"

# Inform user about log file
echo ""
log_message "Deployment log saved to: $LOG_FILE"