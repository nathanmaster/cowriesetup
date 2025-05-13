#!/bin/bash

set -e

echo "[*] Installing dependencies..."
sudo apt update && sudo apt install -y git python3-venv python3-pip libssl-dev libffi-dev build-essential libpython3-dev authbind netfilter-persistent

echo "[*] Adding Cowrie User..."
sudo adduser --disabled-password --gecos "" cowrie

echo "[*] Cloning Cowrie..."
sudo -u cowrie git clone https://github.com/cowrie/cowrie.git /home/cowrie/cowrie
sudo -u cowrie rm -rf /home/cowrie/cowrie/.git

echo "[*] Setting up Virtual Environment..."
sudo -u cowrie python3 -m venv /home/cowrie/cowrie/cowrie-env
sudo -u cowrie /home/cowrie/cowrie/cowrie-env/bin/pip install --upgrade pip
sudo -u cowrie /home/cowrie/cowrie/cowrie-env/bin/pip install -r /home/cowrie/cowrie/requirements.txt

echo "[*] Setting up Cowrie Configurations..."
sudo -u cowrie cp /home/cowrie/cowrie/etc/cowrie.cfg.dist /home/cowrie/cowrie/etc/cowrie.cfg
sudo -u cowrie cp /home/cowrie/cowrie/etc/userdb.txt.dist /home/cowrie/cowrie/etc/userdb.txt

echo "[*] Installing obscurer..."
git clone https://github.com/411Hall/obscurer.git
cd obscurer
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
python3 obscurer.py --cowrie_path /home/cowrie/cowrie --os ubuntu --version 22.04
cd ..
rm -rf obscurer

echo "[*] Redirecting port 22 to 2222..."
sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
sudo netfilter-persistent save

echo "[*] Starting Cowrie..."
sudo -u cowrie bash -c "cd /home/cowrie/cowrie && source cowrie-env/bin/activate && authbind --deep ./bin/cowrie start"

echo "[✓] Obscured Cowrie honeypot is live!"
