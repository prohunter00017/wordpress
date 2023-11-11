#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install Apache2
echo "Installing Apache2..."
sudo apt-get install -y apache2

# Install Git
echo "Installing Git..."
sudo apt-get install -y git

# Enable Apache2 service
echo "Enabling Apache2 service..."
sudo systemctl enable apache2

# Start Apache2 service
echo "Starting Apache2 service..."
sudo systemctl start apache2

# Prompt for domain
echo "Please enter your domain:"
read domain

# Prompt for SSH Git location
echo "Please enter your SSH Git location:"
read git_location

# Clone the repository to the /var/www/$domain directory
echo "Cloning the repository to the /var/www/$domain directory..."
sudo git clone $git_location /var/www/$domain

# Prompt for GitHub username
echo "Please enter your GitHub username:"
read username

# Prompt for GitHub repository name
echo "Please enter your GitHub repository name:"
read repo

# Prompt for GitHub personal access token
echo "Please enter your GitHub personal access token:"
read token

# The URL of the script on your server that will handle the webhook
webhook_url="http://$domain/webhook-handler-script"

# Create the webhook
echo "Creating the webhook..."
curl -X POST -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$username/$repo/hooks -d '{
  "name": "web",
  "active": true,
  "events": ["push"],
  "config": {
    "url": "'$webhook_url'",
    "content_type": "json"
  }
}'

# Configure Apache to serve the website
echo "Configuring Apache to serve the website..."
echo "<VirtualHost *:80>
    ServerName $domain
    DocumentRoot /var/www/$domain
</VirtualHost>" | sudo tee /etc/apache2/sites-available/$domain.conf

# Enable the site
echo "Enabling the site..."
sudo a2ensite $domain.conf

# Reload Apache to apply the changes
echo "Reloading Apache to apply the changes..."
sudo systemctl reload apache2