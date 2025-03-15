# =================================================================
# COMPUTE MODULE - MAIN CONFIGURATION
# =================================================================
# This module creates and configures the virtual machine that hosts
# the Moodle LMS application with all necessary configurations
# =================================================================

# Create a public IP address for the Moodle VM
resource "azurerm_public_ip" "moodle_public_ip" {
  name                = "${var.vm_name}-pip"  # Naming convention: <vm-name>-pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"  # Static IP ensures it doesn't change after VM restarts
  sku                 = "Basic"   # Basic SKU is sufficient for this use case
  tags                = var.tags
  
  # Adding a domain name label for DNS resolution
  domain_name_label   = lower(var.vm_name)  # Creates a FQDN like moodle-vm.westeurope.cloudapp.azure.com
}

# Create a network interface for the Moodle VM
resource "azurerm_network_interface" "moodle_nic" {
  name                = "${var.vm_name}-nic"  # Naming convention: <vm-name>-nic
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id  # Connect to the web tier subnet
    private_ip_address_allocation = "Dynamic"      # Dynamically assign a private IP
    public_ip_address_id          = azurerm_public_ip.moodle_public_ip.id  # Attach the public IP
  }
}

# =================================================================
# VM INITIALIZATION SCRIPT
# =================================================================
# Prepare the custom data script for VM initialization using heredoc syntax
locals {
  moodle_setup_script = <<-EOT
#!/bin/bash
# cloud-config
# vim: syntax=yaml

# Set up logging for better debugging
exec > >(tee /var/log/moodle-setup.log|logger -t moodle-setup -s 2>/dev/console) 2>&1
echo "Starting Moodle setup script at $(date)"

# =================================================================
# MOODLE SETUP SCRIPT
# =================================================================
# This script installs and configures all necessary components
# for running Moodle LMS on Ubuntu 20.04
# =================================================================

# Set to exit script if any command fails for better error detection
set -e

# =================================================================
# SYSTEM PREPARATION
# =================================================================

# Check if cloud-init is installed and install if needed
if ! command -v cloud-init &> /dev/null; then
    echo "Installing cloud-init..."
    apt-get update
    apt-get install -y cloud-init
fi

# Update package repositories and upgrade existing packages
echo "Updating system packages..."
apt update
apt upgrade -y

# Add PHP repository to get the required PHP version
echo "Setting up PHP repository..."
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update

# =================================================================
# WEB SERVER INSTALLATION
# =================================================================

# Install Apache web server
echo "Installing Apache web server..."
apt install -y apache2

# Install PHP 8.1 with all extensions required by Moodle
echo "Installing PHP 8.1 and required extensions..."
apt install -y php8.1 libapache2-mod-php8.1
apt install -y php8.1-common php8.1-curl php8.1-gd php8.1-intl php8.1-mbstring
apt install -y php8.1-xml php8.1-xmlrpc php8.1-soap php8.1-zip php8.1-pgsql 
apt install -y php8.1-opcache

# Install additional utilities needed for full Moodle functionality
echo "Installing additional utilities for Moodle..."
apt install -y graphviz aspell ghostscript clamav

# =================================================================
# APACHE CONFIGURATION
# =================================================================

# Enable necessary Apache modules for Moodle
echo "Enabling Apache modules..."
a2enmod ssl rewrite headers
a2enmod php8.1

# =================================================================
# MOODLE INSTALLATION
# =================================================================

# Create directory for Moodle installation
echo "Creating Moodle installation directory..."
mkdir -p /var/www/html/moodle

# Download the latest stable Moodle release
echo "Downloading Moodle..."
cd /tmp
wget https://download.moodle.org/download.php/direct/stable405/moodle-4.5.2.tgz
# Fallback URL if the first one fails
if [ $? -ne 0 ]; then
  echo "Primary download failed, trying fallback URL..."
  wget https://download.moodle.org/stable/4.1/moodle-4.1.7.tgz
fi

# Extract Moodle files to web directory
echo "Extracting Moodle files..."
tar -xvzf moodle-*.tgz -C /var/www/html

# IMPORTANT: Remove any automatically generated config.php to avoid conflicts
echo "Removing default config.php if it exists..."
rm -f /var/www/html/moodle/config.php

# =================================================================
# DIRECTORY SETUP AND PERMISSIONS
# =================================================================

# Set appropriate permissions on the web root directory
echo "Setting directory permissions..."
chmod 777 /var/www/html

# Create moodledata directorie with proper permissions
echo "Creating moodledata directories..."
mkdir -p /var/www/html/moodledata
chmod 777 /var/www/html/moodledata


# Set proper ownership for all directories
echo "Setting directory ownership..."
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/moodledata
chown -R www-data:www-data /var/www/html/moodledata

# =================================================================
# APACHE SITE CONFIGURATION
# =================================================================

# Configure Apache for Moodle - Creating a dedicated virtual host
echo "Configuring Apache for Moodle..."
tee /etc/apache2/sites-available/moodle.conf > /dev/null << 'EOF'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/moodle
    
    <Directory /var/www/html/moodle>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Enable the Moodle site and disable the default site
echo "Enabling Moodle site in Apache..."
a2ensite moodle.conf
a2dissite 000-default.conf

# =================================================================
# PHP CONFIGURATION
# =================================================================

# Configure PHP settings for optimal Moodle performance
echo "Configuring PHP for Moodle..."
bash -c 'cat > /etc/php/8.1/apache2/conf.d/99-moodle.ini << EOF
max_input_vars = 5000
memory_limit = 256M
post_max_size = 50M
upload_max_filesize = 50M
max_execution_time = 300
EOF'

# Restart Apache to apply settings
echo "Restarting Apache..."
systemctl restart apache2

# Create a marker file to indicate successful completion
echo "Setup completed successfully at $(date)" > /var/log/moodle-setup-complete

echo "Moodle setup complete."
EOT
}


# =================================================================
# VIRTUAL MACHINE CONFIGURATION
# =================================================================
# Create the Linux VM that will host Moodle
resource "azurerm_linux_virtual_machine" "moodle_vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size  # VM size determines compute resources and cost
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  disable_password_authentication = false  # Allow password authentication for simplicity
  network_interface_ids = [azurerm_network_interface.moodle_nic.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"  # Improves disk performance
    storage_account_type = "Standard_LRS"  # Standard locally redundant storage
    disk_size_gb         = 30  # 30 GB is sufficient for OS and Moodle
  }

  # Use Ubuntu 20.04 LTS as the base image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  
  # Pass the setup script as base64-encoded custom data
  custom_data = base64encode(local.moodle_setup_script)
  
  # Use a null_resource with a depends_on to verify script execution after VM is fully ready
}

# Separate null_resource for script verification to allow more control over the connection
resource "null_resource" "verify_script_execution" {
  # Only run this after the VM is fully provisioned
  depends_on = [azurerm_linux_virtual_machine.moodle_vm]

  # Add a small delay to ensure VM is fully booted and network is stable
  provisioner "local-exec" {
    command = "sleep 120"  # 2-minute delay
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Checking if cloud-init completed...'",
      "sudo cloud-init status || echo 'Cloud-init status command failed'",
      "echo 'Checking for setup completion marker...'",
      "if sudo test -f /var/log/moodle-setup-complete; then",
      "  echo 'Moodle setup completed successfully'",
      "  sudo cat /var/log/moodle-setup-complete",
      "else",
      "  echo 'Moodle setup marker file not found'",
      "  echo 'Checking if setup log exists...'",
      "  if sudo test -f /var/log/moodle-setup.log; then",
      "    echo 'Displaying last 50 lines of setup log:'",
      "    sudo tail -n 50 /var/log/moodle-setup.log",
      "  else",
      "    echo 'Setup log not found. Checking cloud-init logs:'",
      "    sudo grep -r moodle /var/log/cloud-init* || echo 'No moodle references in cloud-init logs'",
      "  fi",
      "fi"
    ]

    connection {
      type                = "ssh"
      user                = var.admin_username
      password            = var.admin_password
      host                = azurerm_public_ip.moodle_public_ip.ip_address
      timeout             = "5m"
      agent               = false
      
    }
  }
}