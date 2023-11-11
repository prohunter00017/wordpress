#!/bin/bash

# Update package lists
sudo apt-get update

# Install Apache2
sudo apt-get install -y apache2

# Install Git
sudo apt-get install -y git

# Enable Apache2 service
sudo systemctl enable apache2

# Start Apache2 service
sudo systemctl start apache2

# Domain
domain=$1

# SSH Git location
git_location=$2

# Clone the repository to the /var/www/$domain directory
sudo git clone $git_location /var/www/$domain

# GitHub username
username=$3

# GitHub repository name
repo=$4

# GitHub personal access token
token=$5

# Webhook URL
webhook_url=$6

# Create the webhook
curl -X POST -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$username/$repo/hooks -d '{
  "name": "web",
  "active": true,
  "events": ["push"],
  "config": {
    "url": "'$webhook_url'",
    "content_type": "json"
  }
}'

# Install Certbot
sudo apt-get install -y certbot python3-certbot-apache

# Obtain and install SSL certificate
sudo certbot --apache -n --agree-tos --email zkounima1@protonmail.com -d $domain

# Configure Apache to serve the website
echo "<VirtualHost *:80>
    ServerName $domain
    DocumentRoot /var/www/$domain
</VirtualHost>" | sudo tee /etc/apache2/sites-available/$domain.conf

# Enable the site
sudo a2ensite $domain.conf

# Reload Apache to apply the changes
sudo systemctl reload apache2