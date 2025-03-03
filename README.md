# Moodle Azure 

A comprehensive solution for deploying Moodle Learning Management System (LMS) on Microsoft Azure using HashiCorp Terraform.

## Project Overview

This project provides Infrastructure as Code (IaC) implementation using Terraform to automate the deployment of a production-ready Moodle instance on Azure. The deployment includes all necessary components:

- Virtual machines with auto-scaling capabilities
- Managed database services
- Networking and security configurations
- Storage solutions for Moodle data
- Monitoring and logging services

## Architecture

![Moodle Azure Architecture](docs/images/architecture-diagram.png)
COMING SOON

The solution implements a scalable, highly available architecture:

- Web tier: Azure Virtual Machine Scale Sets running Apache and PHP
- Database tier: Azure Database for MySQL/MariaDB
- File storage: Azure Storage Account with File Shares
- Cache layer: Azure Redis Cache for session management
- CDN: Azure CDN for static content delivery
- Security: Network Security Groups, Azure Key Vault for secrets
- Monitoring: Azure Monitor and Application Insights

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.5.0+)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (v2.45.0+)
- Azure subscription with Contributor access
- [Git](https://git-scm.com/downloads)

## Getting Started

### Authentication Setup

```bash
# Login to Azure
az login

# Set the subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Deployment

1. Clone the repository
```bash
git clone https://github.com/your-username/azure-moodle-terraform-deployment.git
cd azure-moodle-terraform-deployment
```

2. Initialize Terraform
```bash
terraform init
```

3. Customize the deployment by creating a `terraform.tfvars` file:
```bash
cp example.tfvars terraform.tfvars
# Edit terraform.tfvars with your specific configuration
```

4. Review the execution plan
```bash
terraform plan
```

5. Apply the configuration
```bash
terraform apply
```

6. After deployment completes, access the Moodle URL provided in the outputs

## Project Structure

```
azure-moodle-terraform-deployment/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Input variables declaration
├── outputs.tf           # Output values
├── providers.tf         # Provider configuration
├── example.tfvars       # Example variable values
├── modules/             # Terraform modules
│   ├── networking/      # Network infrastructure
│   ├── database/        # Database resources
│   ├── compute/         # VM and scale set configuration
│   ├── storage/         # Storage accounts and file shares
│   ├── security/        # Security resources
│   └── moodle/          # Moodle-specific configurations
├── scripts/             # Deployment and configuration scripts
│   ├── moodle-install.sh    # Moodle installation script
│   ├── moodle-config.php    # Moodle configuration template
│   └── setup-database.sql   # Database initialization
├── docs/                # Documentation
│   ├── images/          # Architecture diagrams
│   └── guides/          # Usage guides
└── .github/             # GitHub Actions workflows
    └── workflows/       # CI/CD pipeline definitions
```

## Customization

The deployment can be customized through variables in `terraform.tfvars`:

- Instance sizes and counts
- Database tier and configuration
- Networking settings
- Moodle version and plugins
- Security settings
- High availability options

## Maintenance and Operations

### Scaling

To scale the deployment:

```bash
# Edit terraform.tfvars to adjust scaling parameters
terraform apply
```

### Updates

To update Moodle or infrastructure components:

```bash
# For infrastructure updates
terraform apply

# For Moodle updates, use the provided script
./scripts/update-moodle.sh
```

### Backup and Recovery

The deployment includes:
- Automated database backups
- File storage snapshots
- Disaster recovery configurations

## Security Considerations

This deployment implements security best practices:

- Private networks with restricted access
- Encrypted storage and communications
- Secrets management with Azure Key Vault
- Least privilege access controls
- Web Application Firewall integration

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
