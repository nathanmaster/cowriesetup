# Cowrie Terraform Setup Guide

This guide explains how to deploy and configure a Cowrie honeypot using Terraform and a user data script. It also covers how to verify the setup by running the required commands on your instance.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS CLI or other cloud provider CLI configured (if applicable)
- SSH key pair for accessing the instance

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

### 5. Run Setup Commands

Once logged in, run the following commands to ensure correct operation:

```bash
cd ./cowriesetup
sudo bash cowrie-setup.sh
sudo ./elastic-agent install --url=https://bd207465e008466f8416e541cf6da0b0.fleet.us-central1.gcp.cloud.es.io:443 --enrollment-token=S21xSE1wWUJWNzFGd0pLaWhQLWU6OFB4Wkd5Yi1TeW04V01qVlprYlZtQQ==
```

These commands will:

- Set up Cowrie using the provided script.
- Install and enroll the Elastic Agent for monitoring.

### 6. Verify Operation

- Check that Cowrie is running (e.g., `ps aux | grep cowrie`).
- Check that the Elastic Agent is running and enrolled.

---

**Note:** The user data script automates most of these steps, but running the above commands manually ensures everything is set up correctly.

