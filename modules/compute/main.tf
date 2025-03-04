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

# Update system packages
apt update
apt upgrade -y

# Install required packages
apt install -y apache2 php php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-pgsql

# Install additional PHP extensions needed for Moodle
apt install -y graphviz aspell ghostscript clamav php-cli php-pspell php-ldap

# Enable needed Apache modules
a2enmod ssl rewrite headers

# Create directory for Moodle installation
mkdir -p /var/www/html/moodle

# Download Moodle - FIXED URL
cd /tmp
wget https://download.moodle.org/download.php/direct/stable401/moodle-4.1.7.tgz
# Fallback URL if the first one fails
if [ $? -ne 0 ]; then
  wget https://download.moodle.org/stable/4.1/moodle-4.1.7.tgz
fi
tar -xvzf moodle-*.tgz -C /var/www/html

# Create moodledata directory for files
mkdir -p /var/moodledata
chmod 777 /var/moodledata

# Set permissions
chown -R www-data:www-data /var/www/html/moodle
chown -R www-data:www-data /var/moodledata

# Mount file share
mkdir -p /mnt/moodleshare
echo "//${var.storage_account_name}.file.core.windows.net/moodlefiles /mnt/moodleshare cifs vers=3.0,username=${var.storage_account_name},password=${var.storage_account_key},dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab
mount -a

# Generate random salt for Moodle
MOODLE_SALT=$(openssl rand -hex 16)

# Configure Moodle
cat > /var/www/html/moodle/config.php <<EOF
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'pgsql';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${var.db_server_fqdn}';
\$CFG->dbname    = '${var.db_name}';
\$CFG->dbuser    = '${var.db_admin_username}@${split(".", var.db_server_fqdn)[0]}';
\$CFG->dbpass    = '${var.db_admin_password}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => '5432',
    'dbhandlesoptions' => false,
    'dbcollation' => 'utf8mb4_unicode_ci',
);

\$CFG->wwwroot   = 'http://${azurerm_public_ip.moodle_public_ip.ip_address}';
\$CFG->dataroot  = '/var/moodledata';
\$CFG->admin     = 'admin';
\$CFG->directorypermissions = 0777;

\$CFG->passwordsaltmain = '\$MOODLE_SALT';

// Enable debugging during initial setup
\$CFG->debug = E_ALL;
\$CFG->debugdisplay = 1;

require_once(__DIR__ . '/lib/setup.php');
EOF

# Configure Apache for Moodle
cat > /etc/apache2/sites-available/moodle.conf <<EOF
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

# Restart Apache
systemctl restart apache2

# Install Moodle via CLI
php /var/www/html/moodle/admin/cli/install.php --lang=en --wwwroot=http://${azurerm_public_ip.moodle_public_ip.ip_address} --dataroot=/var/moodledata --dbtype=pgsql --dbhost=${var.db_server_fqdn} --dbname=${var.db_name} --dbuser=${var.db_admin_username}@${split(".", var.db_server_fqdn)[0]} --dbpass=${var.db_admin_password} --dbport=5432 --prefix=mdl_ --fullname="${var.moodle_site_name}" --shortname="Moodle" --adminuser=${var.moodle_admin_user} --adminpass=${var.moodle_admin_password} --adminemail=${var.moodle_admin_email} --non-interactive --agree-license

# Set up a cron job for Moodle
echo "*/15 * * * * www-data /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null" > /etc/cron.d/moodle

# Configure PHP settings for better performance
cat > /etc/php/7.2/apache2/conf.d/99-moodle.ini <<EOF
max_input_vars = 5000
memory_limit = 256M
post_max_size = 50M
upload_max_filesize = 50M
max_execution_time = 300
EOF

# Restart Apache to apply PHP settings
systemctl restart apache2

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
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  custom_data = base64encode(local.moodle_setup_script)
}