# 🚀 Moodle LMS Deployment on Azure using Terraform

<div align="center">

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Moodle](https://img.shields.io/badge/moodle-%23F98012.svg?style=for-the-badge&logo=moodle&logoColor=white)

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/paullukashuber/moodle-azure-terraform/pulls)

[🌍 English](#overview) | [🇩🇪 Deutsch](#moodle-lms-bereitstellung-auf-azure-mit-terraform)

</div>

## 📋 Overview

This repository contains Infrastructure as Code (IaC) using Terraform to deploy a complete Moodle Learning Management System (LMS) environment on Microsoft Azure. This project was developed as part of the Cloud Computing module at the University of Applied Sciences Weserbergland (Hochschule Weserbergland).

## ✨ Project Description

> **Deploy Moodle LMS in minutes with zero manual configuration**

This project showcases modern **Infrastructure as Code** principles to deploy a production-ready Moodle instance in the cloud. We embrace the [12-Factor App](https://12factor.net/) methodology for cloud-native applications and apply microservices architecture principles for optimal scalability and maintainability.

## 🏗️ Architecture

The deployment follows a multi-tier architecture:

- 🖥️ **Web Tier**: Ubuntu VM running Apache, PHP, and Moodle application
- 🗄️ **Database Tier**: Azure PostgreSQL Flexible Server 
- 📦 **Storage Tier**: Azure Storage accounts for Moodle files and data

Network security groups and subnet separation provide security between tiers, following the principle of least privilege.

## 🔧 Prerequisites

- Azure subscription
- Terraform (>= 1.0)
- Azure CLI
- Git

## 📦 Module Structure

The project is organized into specialized modules for better maintainability and separation of concerns:

```
modules/
├── networking/  # Virtual network, subnets, NSGs
├── compute/     # VM and Moodle installation
├── database/    # PostgreSQL Flexible Server
├── storage/     # Storage accounts for Moodle data
└── security/    # Monitoring and security
```

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/moodle-azure-terraform.git
cd moodle-azure-terraform
```

### 2. Configure Variables

Create a `terraform.tfvars` file with your specific configuration:

```hcl
resource_group_name    = "your-resource-group"
location               = "westeurope"
storage_account_name   = "yourmoodlestorage"  # Must be globally unique
db_admin_password      = "YourSecurePassword123!"
vm_admin_password      = "YourSecurePassword123!"
moodle_admin_password  = "YourSecurePassword123!"
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Preview the changes
terraform plan -out=moodle.tfplan

# Apply the changes
terraform apply "moodle.tfplan"
```

Or use our convenient deployment script:

```bash
chmod +x /scripts/deploy.sh
./scripts/deploy.sh
```

### 4. Access Moodle

After deployment, access your Moodle installation at:

```
http://<vm-ip-address>           # Main Moodle site
http://<vm-ip-address>/admin     # Admin interface
```

> ⏱️ Note: It may take a few minutes for Moodle to fully initialize after deployment.

## 🔒 Security Considerations

This deployment includes several security measures:

- Network security groups with least-privilege access rules
- Subnet isolation for different application tiers
- TLS 1.2 enforcement for storage accounts
- VM monitoring and automated alerts

For production environments, consider these additional enhancements:
- Enable HTTPS with valid SSL certificates
- Implement Azure Key Vault for secret management
- Configure Azure Backup for disaster recovery
- Add Web Application Firewall (WAF) protection

## ⚙️ Customization Options

Customize your deployment through variables in `terraform.tfvars`:

| Component | Customizable Aspects |
|-----------|----------------------|
| VM        | Size, OS, disk space |
| Database  | Tier, performance, backup retention |
| Storage   | Capacity, redundancy level |
| Network   | CIDR ranges, NSG rules |
| Moodle    | Version, site settings |

## 🧹 Cleanup

To delete all resources when they're no longer needed:

```bash
terraform destroy -auto-approve
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

# 🚀 Moodle LMS Bereitstellung auf Azure mit Terraform

<div align="center">

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Moodle](https://img.shields.io/badge/moodle-%23F98012.svg?style=for-the-badge&logo=moodle&logoColor=white)

</div>

## 📋 Überblick

Dieses Repository enthält Infrastructure as Code (IaC) mit Terraform, um eine vollständige Moodle Learning Management System (LMS)-Umgebung auf Microsoft Azure bereitzustellen. Dieses Projekt wurde im Rahmen des Moduls Cloud Computing an der Hochschule Weserbergland entwickelt.

## ✨ Projektbeschreibung

> **Stellen Sie Moodle LMS in Minuten ohne manuelle Konfiguration bereit**

Dieses Projekt demonstriert moderne **Infrastructure-as-Code**-Prinzipien zur Bereitstellung einer produktionsreifen Moodle-Instanz in der Cloud. Wir nutzen die [12-Factor-App](https://12factor.net/)-Methodik für Cloud-native Anwendungen und wenden Prinzipien der Microservices-Architektur für optimale Skalierbarkeit und Wartbarkeit an.

## 🏗️ Architektur

Die Bereitstellung folgt einer mehrstufigen Architektur:

- 🖥️ **Web-Ebene**: Ubuntu VM mit Apache, PHP und Moodle-Anwendung
- 🗄️ **Datenbank-Ebene**: Azure PostgreSQL Flexible Server
- 📦 **Speicher-Ebene**: Azure Storage-Konten für Moodle-Dateien und -Daten

Netzwerksicherheitsgruppen und Subnetz-Trennung bieten Sicherheit zwischen den Ebenen und folgen dem Prinzip der geringsten Berechtigung.

## 🔧 Voraussetzungen

- Azure-Abonnement
- Terraform (>= 1.0)
- Azure CLI
- Git

## 📦 Modulstruktur

Das Projekt ist in spezialisierte Module für bessere Wartbarkeit und Trennung der Zuständigkeiten organisiert:

```
modules/
├── networking/  # Virtuelles Netzwerk, Subnetze, NSGs
├── compute/     # VM und Moodle-Installation
├── database/    # PostgreSQL Flexible Server
├── storage/     # Speicherkonten für Moodle-Daten
└── security/    # Überwachung und Sicherheit
```

## 🚀 Erste Schritte

### 1. Repository klonen

```bash
git clone https://github.com/yourusername/moodle-azure-terraform.git
cd moodle-azure-terraform
```

### 2. Variablen konfigurieren

Erstellen Sie eine `terraform.tfvars`-Datei mit Ihrer spezifischen Konfiguration:

```hcl
resource_group_name    = "ihre-ressourcengruppe"
location               = "westeurope"
storage_account_name   = "ihrmoodlespeicher"  # Muss global eindeutig sein
db_admin_password      = "IhrSicheresPasswort123!"
vm_admin_password      = "IhrSicheresPasswort123!"
moodle_admin_password  = "IhrSicheresPasswort123!"
```

### 3. Initialisieren und Bereitstellen

```bash
# Terraform initialisieren
terraform init

# Änderungen vorab anzeigen
terraform plan -out=moodle.tfplan

# Änderungen anwenden
terraform apply "moodle.tfplan"
```

Oder verwenden Sie unser praktisches Bereitstellungsskript:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 4. Zugriff auf Moodle

Nach der Bereitstellung können Sie auf Ihre Moodle-Installation zugreifen unter:

```
http://<vm-ip-adresse>           # Moodle-Hauptseite
http://<vm-ip-adresse>/admin     # Admin-Oberfläche
```

> ⏱️ Hinweis: Es kann einige Minuten dauern, bis Moodle nach der Bereitstellung vollständig initialisiert ist.

## 🔒 Sicherheitsüberlegungen

Diese Bereitstellung umfasst mehrere Sicherheitsmaßnahmen:

- Netzwerksicherheitsgruppen mit Zugriffsregeln nach dem Prinzip der geringsten Berechtigung
- Subnetz-Isolation für verschiedene Anwendungsebenen
- TLS 1.2-Durchsetzung für Speicherkonten
- VM-Überwachung und automatisierte Warnungen

Für Produktionsumgebungen sollten Sie diese zusätzlichen Verbesserungen in Betracht ziehen:
- HTTPS mit gültigen SSL-Zertifikaten aktivieren
- Azure Key Vault für die Verwaltung von Geheimnissen implementieren
- Azure Backup für die Notfallwiederherstellung konfigurieren
- Web Application Firewall (WAF)-Schutz hinzufügen

## ⚙️ Anpassungsoptionen

Passen Sie Ihre Bereitstellung über Variablen in `terraform.tfvars` an:

| Komponente | Anpassbare Aspekte |
|------------|-------------------|
| VM         | Größe, Betriebssystem, Speicherplatz |
| Datenbank  | Tier, Leistung, Backup-Aufbewahrung |
| Speicher   | Kapazität, Redundanzstufe |
| Netzwerk   | CIDR-Bereiche, NSG-Regeln |
| Moodle     | Version, Site-Einstellungen |

## 🧹 Bereinigung

Um alle Ressourcen zu löschen, wenn sie nicht mehr benötigt werden:

```bash
terraform destroy -auto-approve
```

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe die [LICENSE](LICENSE)-Datei für Details.