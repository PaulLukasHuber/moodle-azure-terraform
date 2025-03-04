#!/bin/bash

# This script installs and configures Moodle on a Ubuntu server
# It is used as a custom data script during VM creation

# Exit on any error
set -e

# Update system
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

# Download Moodle - UPDATED URL
cd /tmp
wget https://download.moodle.org/download.php/direct/stable401/moodle-4.1.7.tgz
# Fallback if the above URL doesn't work
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

# Mount Azure file share
# These parameters will be replaced dynamically by Terraform
mkdir -p /mnt/moodleshare
echo "//${STORAGE_ACCOUNT_NAME}.file.core.windows.net/${SHARE_NAME} /mnt/moodleshare cifs vers=3.0,username=${STORAGE_ACCOUNT_NAME},password=${STORAGE_ACCOUNT_KEY},dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab
mount -a

# Configure Moodle
# These parameters will be replaced dynamically by Terraform
cat > /var/www/html/moodle/config.php <<EOF
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'pgsql';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${DB_SERVER_FQDN}';
\$CFG->dbname    = '${DB_NAME}';
\$CFG->dbuser    = '${DB_USER}@${DB_SERVER_NAME}';
\$CFG->dbpass    = '${DB_PASSWORD}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => '5432',
    'dbhandlesoptions' => false,
    'dbcollation' => 'utf8mb4_unicode_ci',
);

\$CFG->wwwroot   = 'http://${VM_PUBLIC_IP}';
\$CFG->dataroot  = '/var/moodledata';
\$CFG->admin     = 'admin';
\$CFG->directorypermissions = 0777;

\$CFG->passwordsaltmain = '${MOODLE_SALT}';

// Enable debugging during setup
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
    
    ErrorLog \${APACHE_LOG_DIR}/moodle_error.log
    CustomLog \${APACHE_LOG_DIR}/moodle_access.log combined
</VirtualHost>
EOF

# Enable the Moodle site and disable the default site
a2ensite moodle.conf
a2dissite 000-default.conf

# Restart Apache
systemctl restart apache2

# Install Moodle via CLI
php /var/www/html/moodle/admin/cli/install.php \
  --lang=en \
  --wwwroot=http://${VM_PUBLIC_IP} \
  --dataroot=/var/moodledata \
  --dbtype=pgsql \
  --dbhost=${DB_SERVER_FQDN} \
  --dbname=${DB_NAME} \
  --dbuser=${DB_USER}@${DB_SERVER_NAME} \
  --dbpass=${DB_PASSWORD} \
  --dbport=5432 \
  --prefix=mdl_ \
  --fullname="${MOODLE_SITE_NAME}" \
  --shortname="Moodle" \
  --adminuser=${MOODLE_ADMIN_USER} \
  --adminpass=${MOODLE_ADMIN_PASSWORD} \
  --adminemail=${MOODLE_ADMIN_EMAIL} \
  --non-interactive \
  --agree-license

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

echo "Moodle installation completed successfully!"