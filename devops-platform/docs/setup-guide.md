# DevOps Platform - Setup Guide

## Complete Step-by-Step Setup Instructions

> **Estimated Time**: 45 minutes  
> **Difficulty**: Beginner-Friendly  
> **Prerequisites**: AWS account, basic terminal knowledge

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: AWS Account Setup](#step-1-aws-account-setup)
3. [Step 2: Install Local Tools](#step-2-install-local-tools)
4. [Step 3: Infrastructure with Terraform](#step-3-infrastructure-with-terraform)
5. [Step 4: Configuration with Ansible](#step-4-configuration-with-ansible)
6. [Step 5: Deploy Applications](#step-5-deploy-applications)
7. [Step 6: Verify Deployment](#step-6-verify-deployment)
8. [Step 7: Cleanup](#step-7-cleanup)

---

## Prerequisites

### AWS Account
- [ ] AWS account created ([Create here](https://aws.amazon.com/))
- [ ] Free Tier eligible
- [ ] Billing alerts enabled (recommended)

### Computer Requirements
- [ ] 10 GB free disk space
- [ ] 4 GB RAM minimum
- [ ] Internet connection
- [ ] Terminal/PowerShell/Command Prompt access

### Software (to be installed in Step 2)
- [ ] Git
- [ ] Terraform (v1.0+)
- [ ] AWS CLI v2
- [ ] Ansible (v2.10+)

### Knowledge
- [ ] Basic terminal commands
- [ ] Understanding of SSH
- [ ] Basic understanding of cloud concepts

---

## Step 1: AWS Account Setup

### 1.1 Create IAM User (Recommended for Security)

**Why?** Don't use root account for daily operations.

```bash
# Go to AWS Console
# → IAM → Users → Create User

# Set username: devops-user
# Attach policies:
#   - AmazonEC2FullAccess
#   - AmazonVPCFullAccess
#   - IAMFullAccess (for key pair)
```

### 1.2 Create Access Keys

```bash
# In AWS Console
# → Users → devops-user → Security credentials
# → Create Access Key
# → Download CSV file (KEEP THIS SAFE!)
```

### 1.3 Enable Billing Alerts

```bash
# AWS Console → Billing → Billing Preferences
# ✓ Enable: Receive Free Tier Usage Alerts
# ✓ Enable: Receive Billing Alerts
# Set threshold: $5.00
```

### 1.4 Check Free Tier Limits

Free Tier includes (first 12 months):
- ✅ 750 hours EC2 (t2.micro)
- ✅ 30 GB storage
- ✅ Data transfer (some included)
- ✅ VPC and Elastic IPs

**Cost Estimate for This Project: $0 (within free tier)**

---

## Step 2: Install Local Tools

### On Windows

#### 2.1 Install Git

```powershell
# Option 1: Using Chocolatey (if installed)
choco install git

# Option 2: Download from https://git-scm.com/download/win
# Run installer and follow prompts
```

**Verify Installation:**
```powershell
git --version
# Output: git version 2.x.x
```

#### 2.2 Install Terraform

```powershell
# Option 1: Download from https://www.terraform.io/downloads.html
# Extract and add to PATH

# Option 2: Using Chocolatey
choco install terraform
```

**Verify Installation:**
```powershell
terraform --version
# Output: Terraform v1.x.x
```

#### 2.3 Install AWS CLI v2

```powershell
# Download from:
# https://awscli.amazonaws.com/AWSCLIV2.msi

# Or using Chocolatey:
choco install awscliv2
```

**Verify Installation:**
```powershell
aws --version
# Output: aws-cli/2.x.x
```

#### 2.4 Install Ansible

```powershell
# Ansible requires WSL2 on Windows
# Option 1: Use WSL2 (recommended)
wsl --install

# In WSL2:
sudo apt update
sudo apt install -y python3-pip
pip3 install ansible

# Option 2: Or run Ansible from EC2 after provisioning
```

**Verify Installation:**
```bash
ansible --version
# Output: ansible [core 2.x.x]
```

---

## Step 3: Infrastructure with Terraform

### 3.1 Configure AWS Credentials

```bash
# Set environment variables (recommended for scripts)
# Windows PowerShell:
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
$env:AWS_DEFAULT_REGION="us-east-1"

# Or use AWS CLI configuration:
aws configure
# Enter:
# AWS Access Key ID: [paste from CSV]
# AWS Secret Access Key: [paste from CSV]
# Default region: us-east-1
# Default output format: json
```

### 3.2 Clone Repository

```bash
# Clone or download the project
git clone https://github.com/your-repo/devops-platform.git
cd devops-platform

# Or if you downloaded as ZIP
unzip devops-platform.zip
cd devops-platform
```

### 3.3 Review Terraform Configuration

```bash
# Navigate to terraform directory
cd terraform

# Review what will be created
cat terraform.tfvars

# Key values to understand:
# - aws_region: us-east-1 (change if needed)
# - instance_type: t2.micro (FREE TIER)
# - root_volume_size: 20 GB
# - key_pair_name: devops-platform-key
```

### 3.4 Initialize Terraform

```bash
# First time only - downloads providers
terraform init

# Expected output:
# - Downloads AWS provider
# - Initializes backend
# - Ready to use Terraform

# What happens:
# ✓ Creates .terraform/ directory
# ✓ Downloads plugins
# ✓ Initializes working directory
```

### 3.5 Plan Deployment

```bash
# See what will be created (no changes yet)
terraform plan

# This will show:
# + aws_vpc (create)
# + aws_internet_gateway (create)
# + aws_subnet (create)
# + aws_instance (create)
# + ... more resources

# REVIEW THIS CAREFULLY!
# Make sure resources match your expectations
```

### 3.6 Apply Configuration

```bash
# Actually create the resources
terraform apply

# When asked "Do you want to perform these actions?"
# Type: yes

# Terraform will:
# ✓ Create VPC and networking
# ✓ Create Security Groups
# ✓ Create EC2 instance
# ✓ Create Elastic IP
# ✓ Generate SSH key pair

# Time to complete: 3-5 minutes

# After completion, you'll see outputs:
# - Elastic IP address
# - SSH command
# - Application URLs
```

### 3.7 Save Important Information

```bash
# Copy and save these values
terraform output

# Important outputs:
# - elastic_ip: Your public IP (use this!)
# - ssh_key_file: devops-platform-key.pem
# - ssh_command: SSH login command
```

### 3.8 Verify EC2 Instance

```bash
# Check instance is running
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'

# Expected output:
# i-0abc1def2...  running  54.123.45.67
```

### 3.9 Test SSH Connection

```bash
# From terraform directory:
ELASTIC_IP=$(terraform output -raw elastic_ip)

# Test connection (may take 2-3 minutes after apply)
ssh -i devops-platform-key.pem -o StrictHostKeyChecking=no ubuntu@$ELASTIC_IP "echo 'SSH connection successful'"

# If connection refused, wait a few minutes
# EC2 needs time to initialize
```

---

## Step 4: Configuration with Ansible

### 4.1 Copy SSH Key to Ansible Directory

```bash
# From devops-platform root directory
cp terraform/devops-platform-key.pem ansible/

# Verify permissions
ls -la ansible/devops-platform-key.pem
# Should show: -rw------- (600 permissions)
```

### 4.2 Update Ansible Inventory

```bash
# Edit inventory with your EC2 IP
cd ansible

# Get your EC2 IP
ELASTIC_IP=$(cd ../terraform && terraform output -raw elastic_ip)

# Update inventory
sed -i "s/REPLACE_WITH_EC2_PUBLIC_IP/$ELASTIC_IP/" inventory.ini

# Verify it was updated
grep -A 2 "\[devops_platform\]" inventory.ini
```

### 4.3 Test Ansible Connection

```bash
# Ping all hosts
ansible all -i inventory.ini -m ping

# Expected output:
# ec2_instance | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }

# If fails:
# - Check SSH key permissions (should be 0600)
# - Check EC2 is fully initialized
# - Check security group allows SSH (port 22)
```

### 4.4 Run Ansible Playbook

```bash
# Execute configuration management
ansible-playbook -i inventory.ini playbook.yml

# This will:
# ✓ Update system packages
# ✓ Install Docker
# ✓ Install Docker Compose
# ✓ Configure Nginx
# ✓ Deploy applications
# ✓ Start Jenkins

# Time to complete: 5-10 minutes

# Watch for:
# ✓ All tasks should be green
# ⚠ Warnings are usually OK
# ✗ Errors need investigation
```

### 4.5 Verify Ansible Completed Successfully

```bash
# If no errors, all services installed

# Check Ansible output for:
# - "fatal: [ec2_instance]" = ERROR (problem)
# - "ok: [ec2_instance]" = SUCCESS (good)
# - "changed: [ec2_instance]" = CHANGED (good)

# Summary should show all "ok" or "changed"
```

---

## Step 5: Deploy Applications

### 5.1 Verify Docker Containers Running

```bash
# SSH into EC2 instance
ELASTIC_IP=$(cd terraform && terraform output -raw elastic_ip)
ssh -i devops-platform-key.pem ubuntu@$ELASTIC_IP

# Inside EC2:
docker-compose ps

# Expected output:
# NAME                    STATUS
# nginx-reverse-proxy     Up 2 minutes
# portfolio-app           Up 2 minutes
# weather-app             Up 2 minutes
# stopwatch-app           Up 2 minutes
# tic-tac-toe-app         Up 2 minutes
# jenkins-server          Up 2 minutes
```

### 5.2 Check Service Status

```bash
# Inside EC2:

# Check Nginx
sudo systemctl status nginx

# Check Docker
docker ps -a

# Check logs
docker-compose logs nginx
docker-compose logs portfolio
```

### 5.3 Manual Deployment (if needed)

```bash
# SSH into instance
ssh -i devops-platform-key.pem ubuntu@$ELASTIC_IP

# Navigate to deployment directory
cd /opt/devops-platform

# View docker-compose file
cat docker-compose.yml

# Restart services if needed
docker-compose down
docker-compose up -d

# View logs
docker-compose logs -f
```

---

## Step 6: Verify Deployment

### 6.1 Access Applications via Browser

Get your Elastic IP:
```bash
cd terraform
terraform output -raw elastic_ip
# Output: 54.123.45.67
```

Open in browser:
- **Portfolio**: http://54.123.45.67/portfolio
- **Weather**: http://54.123.45.67/weather
- **Stopwatch**: http://54.123.45.67/stopwatch
- **Tic Tac Toe Game**: http://54.123.45.67/game
- **Jenkins**: http://54.123.45.67:8080

### 6.2 Check Jenkins Setup

```bash
# Access Jenkins at http://EC2_IP:8080

# First time setup:
# 1. Get initial admin password from EC2:
#    ssh -i key.pem ubuntu@EC2_IP
#    sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# 2. Paste password in Jenkins UI
# 3. Install recommended plugins
# 4. Create first admin user
```

### 6.3 Verify Nginx Reverse Proxy

```bash
# SSH into EC2
ssh -i devops-platform-key.pem ubuntu@$ELASTIC_IP

# Test endpoints
curl -s http://localhost/portfolio | head -20
curl -s http://localhost/weather | head -20
curl -s http://localhost/stopwatch | head -20
curl -s http://localhost/game | head -20

# Should return HTML content
```

### 6.4 Check Resource Usage

```bash
# SSH into EC2
ssh -i devops-platform-key.pem ubuntu@$ELASTIC_IP

# Check CPU/Memory
docker stats

# Check disk
df -h

# Check network
netstat -tulpn | grep LISTEN
```

---

## Step 7: Cleanup (When Done)

### ⚠️ Important: Prevent Unexpected Charges

When finished learning, clean up resources to avoid charges.

### 7.1 Stop Containers (Temporary)

```bash
# SSH into EC2
ssh -i devops-platform-key.pem ubuntu@$ELASTIC_IP

# Stop all containers (keep EC2 running)
docker-compose down

# Exit SSH
exit
```

### 7.2 Destroy All Resources (Permanent)

```bash
# From devops-platform/terraform directory
cd terraform

# See what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# When asked "Do you really want to destroy?"
# Type: yes

# Terraform will:
# ✓ Terminate EC2 instance
# ✓ Delete Elastic IP
# ✓ Delete VPC and subnets
# ✓ Delete security groups
# ✓ Delete key pair

# Time to complete: 2-3 minutes

# Verify in AWS Console:
# → EC2 Dashboard → Instances
# Should show no instances
```

### 7.3 Verify Cleanup

```bash
# Check AWS CLI
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[]'
# Should return empty list

# Check elastic IPs
aws ec2 describe-addresses --region us-east-1
# Should show none allocated
```

---

## Troubleshooting

### Terraform Apply Fails

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check region
aws ec2 describe-availability-zones

# Re-initialize Terraform
terraform init

# Try apply again
terraform apply
```

### Ansible Connection Fails

```bash
# Check SSH works
ssh -i devops-platform-key.pem ubuntu@<elastic_ip> "echo OK"

# Check inventory
ansible-inventory -i inventory.ini --list

# Check key permissions
ls -la devops-platform-key.pem
# Should be -rw------- (600)

# Fix permissions if needed
chmod 600 devops-platform-key.pem
```

### Applications Not Accessible

```bash
# SSH into EC2
ssh -i devops-platform-key.pem ubuntu@<elastic_ip>

# Check Nginx
sudo systemctl status nginx
curl http://localhost/portfolio

# Check Docker containers
docker ps

# View logs
docker-compose logs

# Restart services
docker-compose restart
```

---

## Next Steps

1. ✅ Infrastructure deployed (Terraform)
2. ✅ Server configured (Ansible)
3. ✅ Applications deployed (Docker)
4. ✅ Accessible via reverse proxy (Nginx)

### What to do next:

- [ ] Review [ARCHITECTURE.md](architecture.md) - Understand the system
- [ ] Set up [Jenkins Pipeline](../jenkins/Jenkinsfile) - Enable CI/CD
- [ ] Add [SSL/TLS Certificate](deployment-guide.md#ssl-setup) - Secure with HTTPS
- [ ] Explore [Terraform State Management](deployment-guide.md#remote-state) - For teams
- [ ] Review [Troubleshooting Guide](troubleshooting.md) - Common issues

---

## Summary

| Step | Tool | Time | Cost |
|------|------|------|------|
| 1. AWS Setup | Manual | 10 min | $0 |
| 2. Install Tools | Manual | 10 min | $0 |
| 3. Terraform | Terraform | 5 min | $0 |
| 4. Ansible | Ansible | 10 min | $0 |
| 5. Deploy | Docker | 5 min | $0 |
| 6. Verify | Manual | 5 min | $0 |
| **Total** | | **45 min** | **$0** |

---

## Commands Quick Reference

```bash
# Terraform
terraform init              # Initialize
terraform plan              # Review changes
terraform apply             # Deploy infrastructure
terraform destroy           # Remove infrastructure

# Ansible
ansible all -i inventory.ini -m ping    # Test connectivity
ansible-playbook -i inventory.ini playbook.yml  # Run playbook

# Docker Compose
docker-compose build        # Build images
docker-compose up -d        # Start services
docker-compose down         # Stop services
docker-compose logs -f      # View logs
docker-compose ps           # List containers

# SSH
ssh -i devops-platform-key.pem ubuntu@<EC2_IP>  # Connect to EC2
```

---

**Next**: Read [ARCHITECTURE.md](architecture.md) to understand the system deeper.
