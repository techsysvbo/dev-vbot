# #!/bin/bash

# # Script to install Grafana on Ubuntu
# sudo hostnamectl set-hostname ${new_hostname}

# # Update package list
# echo "Updating package list..."
# sudo apt update -y

# # Install dependencies
# echo "Installing dependencies..."
# sudo apt install -y apt-transport-https software-properties-common wget

# # Add Grafana GPG key
# echo "Adding Grafana GPG key..."
# wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# # Add Grafana APT repository
# echo "Adding Grafana repository..."
# echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# # Update package list again after adding new repository
# echo "Updating package list after adding Grafana repository..."
# sudo apt update -y

# # Install Grafana
# echo "Installing Grafana..."
# sudo apt install -y grafana

# # Start and enable Grafana service
# echo "Starting and enabling Grafana service..."
# sudo systemctl start grafana-server
# sudo systemctl enable grafana-server.service

# # Open firewall port 3000 for Grafana if UFW is active
# if sudo ufw status | grep -q "Status: active"; then
#   echo "Configuring firewall to allow Grafana on port 3000..."
#   sudo ufw allow 3000/tcp
#   sudo ufw reload
# fi

# # Display Grafana status
# echo "Grafana installation complete. Checking service status..."
# sudo systemctl status grafana-server --no-pager

# echo "Grafana is now installed and running."
# echo "Access Grafana at http://your_server_ip:3000 (default credentials: admin/admin)"

# Automation code with Jenkins for the Love 
#!/bin/bash
sudo hostnamectl set-hostname ${new_hostname} &&
sudo apt-get install -y apt-transport-https software-properties-common wget &&
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add - &&
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list &&
sudo apt-get update &&
sudo apt-get install grafana &&
sudo systemctl start grafana-server &&
sudo systemctl enable grafana-server.service
