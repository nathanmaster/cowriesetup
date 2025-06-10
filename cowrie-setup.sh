#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Set variables
COWRIE_USER="cowrie"
COWRIE_HOME="/home/$COWRIE_USER/cowrie"

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing required dependencies..."
sudo apt install -y git python3 python3-venv python3-dev libssl-dev libffi-dev \
    build-essential libpython3-dev libsqlite3-dev virtualenv libbz2-dev \
    libreadline-dev zlib1g-dev libncurses5-dev libncursesw5-dev liblzma-dev

# Create user if not exists
if id "$COWRIE_USER" &>/dev/null; then
    echo "[*] User $COWRIE_USER already exists."
else
    echo "[*] Creating user $COWRIE_USER..."
    sudo adduser --disabled-password --gecos "" $COWRIE_USER
fi

# Switch to cowrie user and set up Cowrie
sudo -u $COWRIE_USER bash <<EOF

echo "[*] Cloning Cowrie repository into $COWRIE_HOME..."
git clone https://github.com/cowrie/cowrie.git $COWRIE_HOME

cd $COWRIE_HOME

echo "[*] Creating Python virtual environment..."
python3 -m venv cowrie-env
sudo -u cowrie -i
cd ~/cowrie
source cowrie-env/bin/activate

echo "[*] Installing Cowrie dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "[*] Copying default configuration..."
cp etc/cowrie.cfg.dist etc/cowrie.cfg
./bin/cowrie start
./bin/cowrie status
echo "[*] Setup complete."

sudo ./elastic-agent install --url=https://bd207465e008466f8416e541cf6da0b0.fleet.us-central1.gcp.cloud.es.io:443 --enrollment-token=S21xSE1wWUJWNzFGd0pLaWhQLWU6OFB4Wkd5Yi1TeW04V01qVlprYlZtQQ==
y

EOF

echo ""
echo "To start Cowrie, run the following commands as the 'cowrie' user:"
echo "--------------------------------------------------"
echo "sudo -u cowrie -i"
echo "cd ~/cowrie"
echo "source cowrie-env/bin/activate"
echo "./bin/cowrie start"
echo "--------------------------------------------------"
