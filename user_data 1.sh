#!/bin/bash

# Wait for any apt processes to finish

# Update and install dependencies
yum update -y
yum install -y git

# Set a password for the default user (e.g., ubuntu)
echo 'ubuntu:!ThisismypasswordandIlovestarwars!' | sudo chpasswd

# Enable password authentication in SSH config
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart ssh

# Clone the Cowrie setup repo

cd /home/ubuntu
sudo git clone https://github.com/gordondavis8379/cowriesetup.git
cd cowriesetup

# Make the setup script executable and clean line endings

sudo chmod +x cowrie-setup.sh
sudo sed -i 's/\r$//' cowrie-setup.sh


curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.18.2-linux-x86_64.tar.gz 
tar xzvf elastic-agent-8.18.2-linux-x86_64.tar.gz
cd elastic-agent-8.18.2-linux-x86_64
sudo ./elastic-agent install --url=https://bd207465e008466f8416e541cf6da0b0.fleet.us-central1.gcp.cloud.es.io:443 --enrollment-token=S21xSE1wWUJWNzFGd0pLaWhQLWU6OFB4Wkd5Yi1TeW04V01qVlprYlZtQQ==

# Run the Cowrie setup script

sudo bash cowrie-setup.sh
