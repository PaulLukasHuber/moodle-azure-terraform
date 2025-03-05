# Public IP for Moodle VM
resource "azurerm_public_ip" "moodle_public_ip" {
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Basic"
  tags                = var.tags
  
  # Adding a domain name label
  domain_name_label   = lower(var.vm_name)
}

# Network interface for Moodle VM
resource "azurerm_network_interface" "moodle_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.moodle_public_ip.id
  }
}

# Prepare custom data script for VM initialization
locals {
  moodle_setup_script = <<-EOT
#!/bin/bash

# Set to exit script if any command fails
set -e

# Update system packages
apt update
apt upgrade -y

# Add PPA repository for PHP 8.1
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update

# Install Apache
apt install -y apache2

# Install PHP 8.1 and required extensions
apt install -y php8.1 libapache2-mod-php8.1
apt install -y php8.1-common php8.1-curl php8.1-gd php8.1-intl php8.1-mbstring
apt install -y php8.1-xml php8.1-xmlrpc php8.1-soap php8.1-zip php8.1-pgsql 
apt install -y php8.1-opcache

# Install additional utilities needed for Moodle
apt install -y graphviz aspell ghostscript clamav

# Enable needed Apache modules
a2enmod ssl rewrite headers
a2enmod php8.1

# Create directory for Moodle installation
mkdir -p /var/www/html/moodle

# Download Moodle - FIXED URL
cd /tmp
wget https://download.moodle.org/download.php/direct/stable405/moodle-4.5.2.tgz
# Fallback URL if the first one fails
if [ $? -ne 0 ]; then
  wget https://download.moodle.org/stable/4.1/moodle-4.1.7.tgz
fi
tar -xvzf moodle-*.tgz -C /var/www/html

# IMPORTANT: Remove any automatically generated config.php file to avoid syntax errors
rm -f /var/www/html/moodle/config.php

# Set appropriate permissions on the web root directory so Moodle can create its data directory
chmod 777 /var/www/html

# Create both possible moodledata directories with proper permissions
mkdir -p /var/moodledata
chmod 777 /var/moodledata
mkdir -p /var/www/html/moodledata
chmod 777 /var/www/html/moodledata

# Set proper ownership for all directories
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/moodledata
chown -R www-data:www-data /var/www/html/moodledata

# Configure Apache for Moodle - Writing the file directly
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
a2ensite moodle.conf
a2dissite 000-default.conf

bash -c 'cat > /etc/php/8.1/apache2/conf.d/99-moodle.ini << EOF
max_input_vars = 5000
memory_limit = 256M
post_max_size = 50M
upload_max_filesize = 50M
max_execution_time = 300
EOF'

# Restart Apache to apply settings
systemctl restart apache2

# Get the current VM's public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com || echo "YOUR_VM_IP_ADDRESS")

# Write installation instructions for the user
cat > /home/azureadmin/moodle_setup_instructions.txt << EOF
Moodle Installation Instructions
===============================

Your Moodle files have been installed and the web server has been configured.
To complete the Moodle setup, follow these steps:

1. Open a web browser and navigate to: http://$PUBLIC_IP

2. You will be presented with the Moodle installation wizard.

3. For the database setup, use these settings:
   - Database type: PostgreSQL
   - Database host: ${var.db_server_fqdn}
   - Database name: ${var.db_name}
   - Database user: ${var.db_admin_username}@${split(".", var.db_server_fqdn)[0]}
   - Database password: (Your database password)
   - Tables prefix: mdl_
   - Database port: 5432

4. For paths, you can use either:
   - Moodle data directory: /var/www/html/moodledata (default)
   OR
   - Moodle data directory: /var/moodledata (more secure)

5. Follow the remaining steps in the wizard to complete the installation.

These instructions are saved in /home/azureadmin/moodle_setup_instructions.txt
EOF

# Make sure the instructions file is readable
chown azureadmin:azureadmin /home/azureadmin/moodle_setup_instructions.txt
chmod 644 /home/azureadmin/moodle_setup_instructions.txt

echo "Moodle files have been installed. Please complete the setup through the web interface."
EOT
}

# Create Moodle VM
resource "azurerm_linux_virtual_machine" "moodle_vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.moodle_nic.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  
  custom_data = base64encode(local.moodle_setup_script)
}