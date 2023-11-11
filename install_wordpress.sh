#!/bin/bash

# Prompt for the domain name
read -p "Please enter your domain name: " domain_name

# Prompt for database details
read -p "Please enter your database name: " db_name
read -p "Please enter your database user: " db_user
read -s -p "Please enter your database password: " db_pass
echo

# Check if domain name is provided
if [ -z "$domain_name" ]; then
    echo "Domain name is required."
    exit 1
fi

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install LAMP stack (Apache, MySQL, PHP)
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql -y

# Configure database for WordPress
echo "CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | sudo mysql -u root
echo "GRANT ALL ON $db_name.* TO '$db_user'@'localhost' IDENTIFIED BY '$db_pass';" | sudo mysql -u root
echo "FLUSH PRIVILEGES;" | sudo mysql -u root

# Download and set up WordPress with the provided domain name
wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz

# Create a new directory for the WordPress site
sudo mkdir -p /var/www/$domain_name

# Copy WordPress files to the new directory
sudo cp -a wordpress/. /var/www/$domain_name

# Adjust Apache configuration for the given domain
# Prompt for the IP address
read -p "Please enter your IP address: " ip_address

# Create Apache configuration file for the domain
sudo bash -c "cat > /etc/apache2/sites-available/$domain_name.conf <<EOF
<VirtualHost $ip_address:80>
    ServerAdmin iamhamzazoubir@outlook.com
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot /var/www/$domain_name
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

# Enable the site
sudo a2ensite $domain_name.conf

# Reload Apache to apply changes
sudo systemctl reload apache2

# Restart Apache
sudo systemctl restart apache2

echo "WordPress installed and configured for domain: $domain_name"