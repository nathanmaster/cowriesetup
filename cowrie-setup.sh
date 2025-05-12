#!/bin/bash

# Exit on error
set -e

echo "[*] Installing dependencies..."
sudo apt update
sudo apt install -y git python3-venv python3-pip libssl-dev libffi-dev build-essential libpython3-dev authbind netfilter-persistent dos2unix

# Add cowrie user if it doesn't exist
if ! id "cowrie" &>/dev/null; then
    echo "[*] Adding Cowrie user..."
    sudo adduser --disabled-password --gecos "" cowrie
fi

# Clone Cowrie repo as cowrie user
echo "[*] Cloning Cowrie..."
sudo -u cowrie bash -c "
    cd ~
    [ -d cowrie ] && rm -rf cowrie
    git clone https://github.com/cowrie/cowrie.git
    cd cowrie
    rm -rf .git
"

# Setup virtual environment as cowrie user
echo "[*] Setting up Virtual Environment..."
sudo -u cowrie bash -c "
    cd ~/cowrie
    python3 -m venv cowrie-env
    source cowrie-env/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
"

# Setup Cowrie config files
echo "[*] Setting up Cowrie Configurations..."
sudo -u cowrie bash -c "
    cd ~/cowrie
    cp etc/cowrie.cfg.dist etc/cowrie.cfg
    cp etc/userdb.txt.dist etc/userdb.txt
"

# Install Obscurer
echo "[*] Installing Obscurer..."
sudo -u cowrie bash -c "
    cd ~
    [ -d obscurer ] && rm -rf obscurer
    git clone https://github.com/411Hall/obscurer.git
    cd obscurer
    python3 -m venv env
    source env/bin/activate
    pip install -r requirements.txt
    python3 obscurer.py --cowrie_path ~/cowrie --os ubuntu --version 22.04
"

# Redirect port 22 to 2222
echo "[*] Redirecting port 22 to 2222..."
sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
sudo netfilter-persistent save

# Start Cowrie
echo "[*] Starting Cowrie..."
sudo -u cowrie bash -c "
    cd ~/cowrie
    source cowrie-env/bin/activate
    authbind --deep ./bin/cowrie start
"

echo "[✓] Obscured Cowrie honeypot is live!"
