echo "Updating package lists..."
sudo apt-get update

echo "Installing Apache2..."
sudo apt-get install -y apache2

echo "Installing Git..."
sudo apt-get install -y git

echo "Enabling Apache2 service..."
sudo systemctl enable apache2

echo "Starting Apache2 service..."
sudo systemctl start apache2

echo "Please enter your domain:"
read domain

echo "Please enter your SSH Git location:"
read git_location

echo "Cloning the repository to the /var/www/$domain directory..."
sudo git clone $git_location /var/www/$domain

echo "Please enter your GitHub username:"
read username

echo "Please enter your GitHub repository name:"
read repo

# GitHub personal access token
token="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"

# The URL of the script on your server that will handle the webhook
webhook_url="http://$domain/webhook-handler-script"

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

echo "Configuring Apache to serve the website..."
echo "<VirtualHost *:80>
    ServerName $domain
    DocumentRoot /var/www/$domain
</VirtualHost>" | sudo tee /etc/apache2/sites-available/$domain.conf

echo "Enabling the site..."
sudo a2ensite $domain.conf

echo "Reloading Apache to apply the changes..."
sudo systemctl reload apache2