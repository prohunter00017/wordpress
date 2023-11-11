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

if [ -z "$domain" ]; then
    echo "Domain is not set. Please enter a valid domain."
    exit 1
fi

# Generate a new SSH key for the domain
echo "Generating a new SSH key for $domain..."
ssh-keygen -t rsa -b 4096 -C "iamhamzazoubir@icloud.com" -f ~/.ssh/$domain -N ""

# Add the new SSH key to the ssh-agent
echo "Adding the new SSH key to the ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/$domain

# Display the public key
echo "Here is your new public key:"
cat ~/.ssh/$domain.pub

# Ask for confirmation
while true; do
    read -p "Have you copied the SSH key? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please copy the SSH key and then continue."; continue;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Create the /var/www/$domain directory
echo "Creating /var/www/$domain directory..."
sudo mkdir -p /var/www/$domain

# Give the www-data user ownership of the directory
echo "Setting ownership of /var/www/$domain to www-data..."
sudo chown -R www-data:www-data /var/www/$domain

# Set the correct permissions on the directory
echo "Setting permissions of /var/www/$domain..."
sudo chmod -R 755 /var/www/$domain

echo "Please enter your SSH Git location:"
read git_location

if [ -z "$git_location" ]; then
    echo "Git location is not set. Please enter a valid Git location."
    exit 1
fi

echo "Cloning the repository to the /var/www/$domain directory..."
if [ -d "/var/www/$domain" ]; then
    echo "/var/www/$domain exists. Removing it..."
    sudo rm -rf /var/www/$domain
    sleep 2  # Wait for 2 seconds to ensure the directory has been fully removed
fi
if ! sudo git clone $git_location /var/www/$domain; then
    echo "Failed to clone repository. Please check your Git location and try again."
    exit 1
fi
sudo chown -R www-data:www-data /var/www/$domain
sudo chmod -R 755 /var/www/$domain

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