# Moodle on Azure with Terraform
This project contains Terraform configuration to deploy a complete Moodle Learning Management System (LMS) on Microsoft Azure.

## Architecture
This deployment creates the following resources:
- Azure App Service for hosting the Moodle application
- Azure Database for MySQL for Moodle data
- Azure Storage Account for Moodle files
- Virtual Network with subnets for web and database
- Network Security Groups for secure communication

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (2.20.0 or newer)
- An Azure subscription
- A user with permissions to create resources in Azure

## Getting Started
1. **Log in to Azure CLI**:
   ```
   az login
   ```
2. **Initialize Terraform**:
   ```
   terraform init
   ```
3. **Create a terraform.tfvars file**:
   Copy the `terraform.tfvars.example` file to `terraform.tfvars` and fill in the required variables.
4. **Review the execution plan**:
   ```
   terraform plan
   ```
5. **Apply the Terraform configuration**:
   ```
   terraform apply
   ```
6. **Access your Moodle LMS**:
   After successful deployment, you can access your Moodle instance at the URL provided in the output.

## Post-Deployment Configuration
After deploying Moodle, you may need to:
1. Complete the Moodle setup wizard (if not automated)
2. Install additional Moodle plugins
3. Configure SSL/TLS for your custom domain
4. Set up backup policies

## Estimated Costs
This deployment is optimized for cost-effectiveness while maintaining adequate performance:
- App Service Basic tier: ~$13/month
- Azure Database for MySQL Basic tier: ~$25/month
- Azure Storage: ~$5/month (depends on usage)
- Additional services (networking, etc.): ~$5/month

Total estimated monthly cost: ~$50/month

## Security Considerations
This deployment includes:
- Network Security Groups to restrict traffic
- SSL enforcement for database connections
- HTTPS-only access for the web application
- Managed identities for secure service-to-service communication

## Security Note for Public Repository

This repository includes a `.terraform.lock.hcl` file to help with consistent provider versions. If you're using this template for your own production deployment, consider running `terraform init -upgrade` to generate a fresh lock file with the latest provider versions.

For a production environment, you should:
1. Review all provider versions for security updates
2. Implement proper secrets management (don't commit .tfvars files)
3. Enable state locking if working in a team
4. Configure access controls and audit logging for your deployed resources

## Modules
- **networking**: Virtual Network, subnets, and NSGs
- **database**: Azure Database for MySQL configuration
- **webapp**: App Service for hosting Moodle
- **storage**: Blob storage for Moodle files

## Best Practices Used
- Modular Terraform structure
- Consistent naming and tagging
- Least-privilege security principles
- Resource optimizations for cost efficiency

## License
This project is licensed under the MIT License - see the LICENSE file for details.