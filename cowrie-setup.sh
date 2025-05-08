#!/bin/bash

# Exit on error
set -e

# Update and install dependencies

echo "[*] Installing dependencies..."
sudo apt update && sudo apt install -y git python3-venv python3-pip libssl-dev libffi-dev build-essential libpython3-dev authbind
 
# Add cowrie user
echo "[*] Adding Cowrie User..."

sudo adduser --disabled-password --gecos "" cowrie
sudo su - cowrie
 
# Clone Cowrie
echo "[*] Cloning Cowrie..."

git clone https://github.com/cowrie/cowrie.git
cd cowrie
rm -rf .git
 
# Setup virtualenv
echo "[*] Setting up Virtual Enviroment..."

python3 -m venv cowrie-env
source cowrie-env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
 
# Setup basic config
echo "[*] Setting up Cowrie Configurations..."

cp etc/cowrie.cfg.dist etc/cowrie.cfg
cp etc/userdb.txt.dist etc/userdb.txt
 

# Install obscurer.py
echo "[*] Installing obscurer..."

cd ~
git clone https://github.com/411Hall/obscurer.git
cd obscurer
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt

# Apply Obscurer to Cowrie install
python3 obscurer.py --cowrie_path ~/cowrie --os ubuntu --version 22.04

# Redirect port 22 to Cowrie
echo "[*] Redirecting port 22 to 2222..."
sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
sudo netfilter-persistent save

#Start cowrie
echo "[*] Starting Cowrie..."
sudo -u cowrie bash -c "cd ~/cowrie && source cowrie-env/bin/activate && authbind --deep ./bin/cowrie start"

echo "[✓] Obscured Cowrie honeypot is live!"