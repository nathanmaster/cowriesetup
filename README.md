# Cowrie Terraform Setup Guide

This guide explains how to deploy and configure a Cowrie honeypot using Terraform and a user data script. It also covers how to verify the setup by running the required commands on your instance.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS CLI or other cloud provider CLI configured (if applicable)
- SSH key pair for accessing the instance

## File Overview

- **main.tf**: The main Terraform configuration file. It defines the infrastructure resources (such as the VM instance), networking, and provisioning steps.
- **user_data.sh**: A shell script provided to the VM as "user data" during creation. It automates the installation of dependencies, cloning the Cowrie setup repository, and initial configuration.
- **cowrie-setup.sh**: The script (cloned from the repo) that installs and configures Cowrie.
- **README.md**: This documentation file.

## How the Setup Works

1. **Terraform** uses `main.tf` to provision a new VM instance.
2. The VM is configured to run `user_data.sh` on first boot.
3. `user_data.sh`:
   - Updates the system and installs dependencies.
   - Clones the Cowrie setup repository into `/home/ubuntu/cowriesetup`.
   - Makes the setup script executable and prepares the Elastic Agent.
   - Sets up SSH password authentication for easy access.
4. After the instance is running, you can SSH in and manually run the setup scripts to verify everything is working.

## Steps

### 1. Initialize Terraform

Run the following command in the project directory to initialize Terraform and download the required providers:

```bash
terraform init
```

### 2. Review and Apply the Terraform Plan

To see what resources will be created, run:

```bash
terraform plan
```

To apply the configuration and create the resources, run:

```bash
terraform apply
```

Confirm the action when prompted.

### 3. Obtain the Instance Public IP

After `terraform apply` completes, note the public IP address of your instance. You can find it in the Terraform output or your cloud provider's console.

### 4. SSH into the Instance

Use the following command to SSH into your instance (replace `<public-ip>` with your instance's IP):

```bash
ssh ubuntu@<public-ip>
```

The default password is:

```
!ThisismypasswordandIlovestarwars!
```

### 5. Clone the Repository or Copy Files (if not using user_data)

If you are not using the provided `user_data.sh` script, you can manually clone the repository or copy the files:

```bash
git clone https://github.com/nathanmaster/cowriesetup.git
cd cowriesetup
```

Alternatively, upload your local files to the instance using `scp`:

```bash
scp -r ./cowriesetup ubuntu@<public-ip>:/home/ubuntu/
```

### 6. Run Setup Commands

Once logged in, run the following commands to ensure correct operation:

```bash
cd ./cowriesetup
sudo bash cowrie-setup.sh
cd ../elastic-agent-8.18.2-linux-x86_64
sudo ./elastic-agent install --url=https://bd207465e008466f8416e541cf6da0b0.fleet.us-central1.gcp.cloud.es.io:443 --enrollment-token=S21xSE1wWUJWNzFGd0pLaWhQLWU6OFB4Wkd5Yi1TeW04V01qVlprYlZtQQ==
```

These commands will:

- Set up Cowrie using the provided script.
- Install and enroll the Elastic Agent for monitoring.

### 7. File Tree After Installation

After installation, your home directory should look like this:

```
/home/ubuntu/
├── cowriesetup/
│   ├── cowrie-setup.sh
│   └── ...other setup files...
├── elastic-agent-8.18.2-linux-x86_64/
│   ├── elastic-agent
│   └── ...other agent files...
├── main.tf
├── user_data 1.sh
└── README.md
```

### 8. Verify Operation

```bash
./bin/cowrie status
```
- Check that Cowrie is running (e.g., `ps aux | grep cowrie`).
- Check that the Elastic Agent is running and enrolled.

---

**Note:** The user data script automates most of these steps, but running the above commands manually ensures everything is set up correctly.



