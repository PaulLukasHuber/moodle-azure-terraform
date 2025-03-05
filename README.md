# Moodle LMS Deployment on Azure using Terraform

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Moodle](https://img.shields.io/badge/moodle-%23F98012.svg?style=for-the-badge&logo=moodle&logoColor=white)

## English | [Deutsch](#moodle-lms-bereitstellung-auf-azure-mit-terraform)

## Overview

This repository contains Infrastructure as Code (IaC) using Terraform to deploy a complete Moodle Learning Management System (LMS) environment on Microsoft Azure. This project was developed as part of the Cloud Computing module at the University of Applied Sciences Weserbergland (Hochschule Weserbergland).

## Project Description

The goal of this project is to demonstrate how to use modern Infrastructure as Code principles to deploy and configure a fully functional Moodle instance in the cloud. The deployment includes:

- Networking infrastructure (VNet, subnets, NSGs)
- Compute resources (Virtual Machine)
- Database (PostgreSQL Flexible Server)
- Storage accounts for Moodle data
- Security configurations and monitoring

The entire infrastructure is defined as code using Terraform, enabling consistent, reproducible deployments and simplifying the management of the infrastructure.

## Architecture

The deployment follows a multi-tier architecture:

- **Web Tier**: Ubuntu VM running Apache, PHP, and Moodle
- **Database Tier**: Azure PostgreSQL Flexible Server
- **Storage Tier**: Azure Storage accounts for Moodle files

Network security groups and subnet separation provide security between tiers.

## Prerequisites

- Azure subscription
- Terraform (>= 1.0)
- Azure CLI
- Git

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/moodle-azure-terraform.git
cd moodle-azure-terraform
```

### 2. Configure Variables

Create a `terraform.tfvars` file with your specific configuration:

```hcl
# Refer to sample-terraform.tfvars in the repository
resource_group_name    = "your-resource-group"
location               = "westeurope"
storage_account_name   = "yourmoodlestorage"
db_admin_password      = "YourSecurePassword123!"
vm_admin_password      = "YourSecurePassword123!"
moodle_admin_password  = "YourSecurePassword123!"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Deploy the Infrastructure

```bash
terraform plan -out=moodle.tfplan
terraform apply "moodle.tfplan"
```

Alternatively, use the provided deployment script:

```bash
chmod +x deploy.sh
./deploy.sh
```

### 5. Access Moodle

After deployment, Terraform will output the URL to access your Moodle installation:

```
Outputs:

moodle_url = "http://your-vm-ip-address"
moodle_admin_url = "http://your-vm-ip-address/admin"
```

Follow the on-screen instructions to complete the Moodle setup.

## Module Structure

- `modules/compute`: VM and Moodle installation
- `modules/database`: PostgreSQL server and database
- `modules/networking`: VNet, subnets, and NSGs
- `modules/security`: Monitoring and security configurations
- `modules/storage`: Storage accounts for Moodle data

## Cleanup

To delete all resources when they're no longer needed:

```bash
terraform destroy
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

# Moodle LMS Bereitstellung auf Azure mit Terraform

## Überblick

Dieses Repository enthält Infrastructure as Code (IaC) mit Terraform, um eine vollständige Moodle Learning Management System (LMS)-Umgebung auf Microsoft Azure bereitzustellen. Dieses Projekt wurde im Rahmen des Moduls Cloud Computing an der Hochschule Weserbergland entwickelt.

## Projektbeschreibung

Das Ziel dieses Projekts ist es, zu demonstrieren, wie moderne Infrastructure-as-Code-Prinzipien genutzt werden können, um eine voll funktionsfähige Moodle-Instanz in der Cloud zu implementieren und zu konfigurieren. Die Bereitstellung umfasst:

- Netzwerkinfrastruktur (VNet, Subnetze, NSGs)
- Rechenressourcen (Virtuelle Maschine)
- Datenbank (PostgreSQL Flexible Server)
- Speicherkonten für Moodle-Daten
- Sicherheitskonfigurationen und Monitoring

Die gesamte Infrastruktur ist als Code mit Terraform definiert, was konsistente, reproduzierbare Bereitstellungen ermöglicht und die Verwaltung der Infrastruktur vereinfacht.

## Architektur

Die Bereitstellung folgt einer mehrstufigen Architektur:

- **Web-Ebene**: Ubuntu VM mit Apache, PHP und Moodle
- **Datenbank-Ebene**: Azure PostgreSQL Flexible Server
- **Speicher-Ebene**: Azure Storage-Konten für Moodle-Dateien

Netzwerksicherheitsgruppen und Subnetz-Trennung bieten Sicherheit zwischen den Ebenen.

## Voraussetzungen

- Azure-Abonnement
- Terraform (>= 1.0)
- Azure CLI
- Git

## Erste Schritte

### 1. Repository klonen

```bash
git clone https://github.com/yourusername/moodle-azure-terraform.git
cd moodle-azure-terraform
```

### 2. Variablen konfigurieren

Erstellen Sie eine `terraform.tfvars`-Datei mit Ihrer spezifischen Konfiguration:

```hcl
# Siehe sample-terraform.tfvars im Repository
resource_group_name    = "ihre-ressourcengruppe"
location               = "westeurope"
storage_account_name   = "ihrmoodlespeicher"
db_admin_password      = "IhrSicheresPasswort123!"
vm_admin_password      = "IhrSicheresPasswort123!"
moodle_admin_password  = "IhrSicheresPasswort123!"
```

### 3. Terraform initialisieren

```bash
terraform init
```

### 4. Infrastruktur bereitstellen

```bash
terraform plan -out=moodle.tfplan
terraform apply "moodle.tfplan"
```

Alternativ können Sie das bereitgestellte Deployment-Skript verwenden:

```bash
chmod +x deploy.sh
./deploy.sh
```

### 5. Moodle zugreifen

Nach der Bereitstellung gibt Terraform die URL aus, um auf Ihre Moodle-Installation zuzugreifen:

```
Outputs:

moodle_url = "http://ihre-vm-ip-adresse"
moodle_admin_url = "http://ihre-vm-ip-adresse/admin"
```

Folgen Sie den Anweisungen auf dem Bildschirm, um die Moodle-Einrichtung abzuschließen.

## Modulstruktur

- `modules/compute`: VM und Moodle-Installation
- `modules/database`: PostgreSQL-Server und Datenbank
- `modules/networking`: VNet, Subnetze und NSGs
- `modules/security`: Überwachung und Sicherheitskonfigurationen
- `modules/storage`: Speicherkonten für Moodle-Daten

## Bereinigung

Um alle Ressourcen zu löschen, wenn sie nicht mehr benötigt werden:

```bash
terraform destroy
```

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe die [LICENSE](LICENSE)-Datei für Details.