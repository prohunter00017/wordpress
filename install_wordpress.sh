#!/bin/bash

# Prompt the user for the domain name
echo "Please enter your domain name:"
read domain_name

# Check if the domain name is provided
if [ -z "$domain_name" ]; then
  echo "Domain name is required."
  exit 1
fi

# Generate database details using the domain name
db_name="${domain_name}_db"
db_user="${domain_name}_user"
db_pass=$(openssl rand -base64 12)

# Update the system's package lists
sudo apt update -y

# Upgrade all the system's packages
sudo apt upgrade -y

# Install Apache, MySQL, PHP (LAMP stack)
sudo apt install apache2 mysql-server php libapache2-mod-php php-mysql -y

# Create a new MySQL database for WordPress
echo "CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | sudo mysql -u root

# Create a new MySQL user for WordPress and grant all privileges on the database to the user
echo "GRANT ALL ON $db_name.* TO '$db_user'@'localhost' IDENTIFIED BY '$db_pass';" | sudo mysql -u root

# Flush the MySQL privileges to apply changes
echo "FLUSH PRIVILEGES;" | sudo mysql -u root

# Download the latest version of WordPress
wget https://wordpress.org/latest.tar.gz

# Extract the downloaded file
tar xzvf latest.tar.gz

# Create a new directory for the WordPress site
sudo mkdir -p /var/www/$domain_name

# Copy the extracted WordPress files to the new directory
sudo cp -a wordpress/. /var/www/$domain_name

# Prompt the user for the IP address
echo "Please enter your IP address:"
read ip_address

# Create an Apache configuration file for the new site
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

# Enable the new site in Apache
sudo a2ensite $domain_name.conf

# Reload Apache to apply the changes
sudo systemctl reload apache2

# Install Certbot (Let's Encrypt client)
sudo apt install certbot python3-certbot-apache -y

# Obtain and install a certificate
sudo certbot --apache -d $domain_name -d www.$domain_name --non-interactive --agree-tos --email iamhamzazoubir@outlook.com

# Restart Apache
sudo systemctl restart apache2

# Print the WordPress and database details
echo "WordPress installed and configured for domain: $domain_name"
echo "Database Name: $db_name"
echo "Database User: $db_user"
echo "Database Password: $db_pass"