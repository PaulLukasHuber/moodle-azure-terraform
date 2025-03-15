#!/bin/bash

# =================================================================
# MOODLE DEPLOYMENT SCRIPT - AZURE VIA TERRAFORM
# =================================================================
# This script automates the deployment of Moodle to Azure using 
# Terraform with comprehensive logging and error handling
# =================================================================

set -e  # Exit immediately if a command exits with non-zero status

# =================================================================
# CONFIGURATION VARIABLES
# =================================================================
LOG_DIR="./logs"
DEPLOY_LOG="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S).log"
INFO_LOG="${LOG_DIR}/deployment_info.txt"
MODULES_DIR="./Modules"

# Color codes for visual terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =================================================================
# HELPER FUNCTIONS
# =================================================================

# Log messages to both console and log file with colors
# Usage: log "message" [INFO|SUCCESS|WARNING|ERROR]
log() {
  local message="$1"
  local level="${2:-INFO}"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  mkdir -p "$LOG_DIR"
  local formatted_message="[$timestamp] [$level] $message"
  echo "$formatted_message" >> "$DEPLOY_LOG"

  # Display with appropriate color based on message level
  case "$level" in
    "INFO") echo -e "${BLUE}$formatted_message${NC}" ;;
    "SUCCESS") echo -e "${GREEN}$formatted_message${NC}" ;;
    "WARNING") echo -e "${YELLOW}$formatted_message${NC}" ;;
    "ERROR") echo -e "${RED}$formatted_message${NC}" ;;
    *) echo "$formatted_message" ;;
  esac
}

# Check if a command exists
# Usage: command_exists terraform
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Verify required dependencies are installed
check_dependencies() {
  log "Checking dependencies..."
  if ! command_exists terraform; then
    log "Terraform is not installed. Please install Terraform." "ERROR"
    exit 1
  fi
  if ! command_exists az; then
    log "Azure CLI is not installed. Please install Azure CLI." "ERROR"
    exit 1
  fi
  log "All dependencies are installed." "SUCCESS"
}

# Verify Azure login status and prompt login if necessary
check_azure_login() {
  log "Checking Azure login status..."
  if ! az account show &>/dev/null; then
    log "Not logged into Azure. Running 'az login'..." "WARNING"
    az login
  fi

  local account=$(az account show --query name -o tsv)
  log "Logged into Azure subscription: $account" "SUCCESS"
}

# Execute Terraform deployment steps
run_terraform() {
  log "Starting Terraform deployment..." "INFO"

  # Initialize Terraform (including modules)
  log "Initializing Terraform..." "INFO"
  terraform init | tee -a "$DEPLOY_LOG"

  # Validate Terraform configuration
  log "Validating Terraform configuration..." "INFO"
  terraform validate | tee -a "$DEPLOY_LOG"

  # Create Terraform plan
  log "Creating Terraform plan..." "INFO"
  terraform plan -out=moodle.tfplan | tee -a "$DEPLOY_LOG"

  # Apply Terraform plan without requiring confirmation
  log "Applying Terraform plan..." "INFO"
  terraform apply -auto-approve moodle.tfplan | tee -a "$DEPLOY_LOG"

  log "Terraform deployment completed successfully." "SUCCESS"
}

# Create a summary file with important deployment information
generate_summary() {
log "Generating deployment summary..." "INFO"

# Create a summary file with terraform outputs
cat > "$INFO_LOG" <<EOF

Moodle Deployment Information (Deployed on $(date))
=======================================================

Resource Group: $(terraform output -raw resource_group_name)
Moodle URL: $(terraform output -raw moodle_url)
Moodle Admin URL: $(terraform output -raw moodle_admin_url)

Connection Instructions:
$(terraform output -raw connection_instructions)

Note: It may take a few minutes for Moodle to fully initialize after deployment.

EOF

log "Deployment information saved to $INFO_LOG" "SUCCESS"

# Also display key information in the console
echo ""
echo -e "${GREEN}Important Information:${NC}"
echo "- Moodle URL: $(terraform output -raw moodle_url)"
echo "- Moodle Admin URL: $(terraform output -raw moodle_admin_url)"
echo "- Resource Group: $(terraform output -raw resource_group_name)"
echo ""
echo "- Connection Instructions:"
echo "$(terraform output -raw connection_instructions)"
}

# =================================================================
# MAIN SCRIPT EXECUTION
# =================================================================

main() {

mkdir -p "$LOG_DIR"

echo -e "${GREEN}"
echo -e "==================================================="
echo -e " Moodle Deployment to Azure via Terraform "
echo -e "==================================================="
echo -e "${NC}"

log "Starting Moodle deployment process..."

check_dependencies
check_azure_login
run_terraform
generate_summary

log ""
log "Detailed deployment log saved to: $DEPLOY_LOG"

}

# Execute the main function
main