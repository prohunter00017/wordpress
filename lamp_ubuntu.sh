#!/bin/bash

# Required Information
export DB_NAME=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1) # generates a random database name
export DB_USER=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1) # generates a random user name
export DB_PASSWORD=$(openssl rand -base64 32) # generates a random password

# Phase One

# Step 1: Update the package lists
sudo apt-get update -y

# Step 2: Install Apache
sudo apt-get install apache2 -y

# Step 3: Enable Apache on boot
sudo systemctl enable apache2

# Step 4: Allow HTTP and HTTPS traffic
sudo ufw allow in "Apache Full"

# Step 5: Install MySQL
sudo apt-get install mysql-server -y

# Step 6: Secure MySQL Installation
# Install expect
sudo apt-get -y install expect

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$DB_PASSWORD\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

# Step 7: Install PHP
sudo apt-get install php libapache2-mod-php php-mysql -y

# Step 8: Test PHP
# This will create a test PHP file in the web root
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/test.php


# Step 9: Install Git
# This command installs Git, a distributed version control system.
sudo apt-get install git -y

# Step 10: Set up GitHub SSH
# This command generates a new SSH key pair. You'll use this for authenticating with GitHub.
ssh-keygen -t rsa -b 4096 -C "iamhamzazoubir@icloud.com"


# This command starts the ssh-agent in the background.
eval "$(ssh-agent -s)"

# This command adds your SSH private key to the ssh-agent.
ssh-add ~/.ssh/id_rsa

# This command displays your public key. You'll need to add this to your GitHub account.
cat ~/.ssh/id_rsa.pub


# Print database details to the terminal
echo "Database Name: $DB_NAME"
echo "User Name: $DB_USER"
echo "Password: $DB_PASSWORD"

# Print SSH public key to the terminal
echo "SSH Public Key:"
cat ~/.ssh/id_rsa.pub