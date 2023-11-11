#!/bin/bash

# Update packages
sudo apt update

# Install dependencies
sudo apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

echo "Dependencies installed successfully."

# Generate a random password
PASSWORD=$(openssl rand -base64 12)

# Create a directory for WordPress
sudo mkdir -p /srv/www

# Change the ownership of the directory
sudo chown www-data: /srv/www

# Download the latest WordPress files
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

echo "WordPress downloaded successfully."

# Create a new MySQL database
sudo mysql -u root -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

# Create a new MySQL user
sudo mysql -u root -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"

# Flush MySQL privileges
sudo mysql -u root -e "FLUSH PRIVILEGES;"

echo "MySQL user and database created successfully."

# Configure WordPress
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i "s/database_name_here/wordpress/g" /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i "s/username_here/wordpressuser/g" /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i "s/password_here/$PASSWORD/g" /srv/www/wordpress/wp-config.php


echo "WordPress configured successfully."

# Configure Apache
echo "<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress/>
        AllowOverride All
    </Directory>
</VirtualHost>" | sudo tee /etc/apache2/sites-available/wordpress.conf

# Enable the site
sudo a2ensite wordpress.conf

# Enable mod_rewrite
sudo a2enmod rewrite

# Restart Apache
sudo service apache2 restart

echo "Apache configured and restarted successfully."

echo "WordPress installation completed successfully."
echo "The password for the 'wordpressuser' MySQL user is: $PASSWORD"