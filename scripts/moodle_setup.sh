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

# Create both possible moodledata directories with proper permissions
# Option 1: Standard location within web directory
echo "Creating moodledata directories..."
mkdir -p /var/www/html/moodledata
chmod 777 /var/www/html/moodledata

# Option 2: More secure location outside web directory
mkdir -p /var/moodledata
chmod 777 /var/moodledata

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