#!/bin/bash

# Update package list
sudo apt-get update

# Install Apache
sudo apt-get install -y apache2

# Start Apache service
sudo systemctl start apache2

# Install Git
sudo apt-get install -y git

# Install PHP
sudo apt-get install -y php libapache2-mod-php php-mysql

# Ask for domain name
echo "Please enter the domain name:"
read domain_name

# Create a directory in /var/www with the domain name if it doesn't exist
if [ ! -d "/var/www/$domain_name" ]; then
    sudo mkdir /var/www/$domain_name
fi

# Change ownership of the directory to www-data
sudo chown -R www-data:www-data /var/www/$domain_name

# Generate SSH key for Apache user
sudo -u www-data ssh-keygen -t rsa -b 4096 -f /var/www/$domain_name/id_rsa

# Print the public key
echo "Here is your public key. You will need to add this to your repository's deploy keys:"
sudo cat /var/www/$domain_name/id_rsa.pub

# Ask for confirmation before proceeding
while true; do
    read -p "Have you added the deploy key to your repository? (yes/no) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please add the deploy key and then run this script again."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Ask for repository SSH URL
echo "Please enter the repository SSH URL (e.g., git@github.com:username/repo.git):"
read repo_url

# Switch to the www-data user and clone the repository
sudo su -l www-data -s /bin/bash << EOF
GIT_SSH_COMMAND="ssh -i /var/www/$domain_name/id_rsa" git clone -f $repo_url /var/www/$domain_name
EOF