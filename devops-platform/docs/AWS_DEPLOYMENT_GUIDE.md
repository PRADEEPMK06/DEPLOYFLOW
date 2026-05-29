# AWS Deployment Guide - DevOps Platform
## Complete Step-by-Step Instructions for AWS Instance Deployment

**Last Updated**: May 2026  
**Estimated Time**: 60-90 minutes  
**Cost**: FREE (within AWS Free Tier)  
**Difficulty**: Intermediate

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites & Requirements](#prerequisites--requirements)
3. [Phase 1: AWS Account & Credentials Setup](#phase-1-aws-account--credentials-setup)
4. [Phase 2: Prepare Local Environment](#phase-2-prepare-local-environment)
5. [Phase 3: Deploy Infrastructure with Terraform](#phase-3-deploy-infrastructure-with-terraform)
6. [Phase 4: Configure Instances with Ansible](#phase-4-configure-instances-with-ansible)
7. [Phase 5: Deploy Applications](#phase-5-deploy-applications)
8. [Phase 6: Verify Deployment](#phase-6-verify-deployment)
9. [Phase 7: Post-Deployment Configuration](#phase-7-post-deployment-configuration)
10. [Troubleshooting](#troubleshooting)
11. [Cleanup & Cost Management](#cleanup--cost-management)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    AWS INFRASTRUCTURE                    │
├─────────────────────────────────────────────────────────┤
│  VPC (10.0.0.0/16)                                      │
│  ├─ Internet Gateway                                    │
│  ├─ Public Subnet (10.0.1.0/24)                        │
│  │  └─ EC2 Instance (t2.micro)                         │
│  │     ├─ Docker                                       │
│  │     ├─ Nginx (Reverse Proxy)                        │
│  │     ├─ Jenkins CI/CD                                │
│  │     └─ Applications (Portfolio, Weather, etc.)      │
│  ├─ Security Group (Firewall)                          │
│  │  ├─ Port 22 (SSH) - For management                 │
│  │  ├─ Port 80 (HTTP)                                  │
│  │  └─ Port 443 (HTTPS)                                │
│  └─ Elastic IP (Static Public IP)                      │
└─────────────────────────────────────────────────────────┘
```

### What Gets Deployed
- ✅ 1 EC2 Instance (t2.micro - FREE tier)
- ✅ Custom VPC with subnets
- ✅ Security groups with firewall rules
- ✅ Nginx reverse proxy
- ✅ Docker with containerized apps
- ✅ Jenkins for CI/CD
- ✅ 4 Web Applications

---

## Prerequisites & Requirements

### AWS Account Requirements
- [ ] Active AWS account (create at https://aws.amazon.com/)
- [ ] Eligible for Free Tier (most new accounts are)
- [ ] Credit/debit card for account verification
- [ ] AWS Management Console access
- [ ] Billing alerts configured (optional but recommended)

### Software to Install Locally
- [ ] **Git** (v2.0+) - Version control
- [ ] **Terraform** (v1.0+) - Infrastructure as Code
- [ ] **AWS CLI** (v2) - Command-line AWS access
- [ ] **Ansible** (v2.10+) - Configuration management
- [ ] **SSH Client** (built-in on Mac/Linux, use PuTTY or OpenSSH on Windows)

### Knowledge Requirements
- ✅ Basic terminal/command-line knowledge
- ✅ Understanding of SSH and key pairs
- ✅ Basic cloud concepts
- ✅ Docker fundamentals (helpful but not required)

### System Requirements
- [ ] 15 GB free disk space
- [ ] 4 GB RAM minimum (8 GB recommended)
- [ ] Stable internet connection (10+ Mbps)
- [ ] Administrator access to install software

### Estimated Costs
- EC2 (t2.micro): FREE (first 750 hours/month)
- VPC & networking: FREE
- Data transfer (limited): FREE
- **Total estimated cost: $0.00/month** ✅

---

## Phase 1: AWS Account & Credentials Setup

### Step 1.1: Create IAM User for Deployment

⚠️ **Security Best Practice**: Never use root AWS account for deployments.

**Instructions:**

1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Search for "IAM" in the search bar
3. Click **Users** → **Create user**
4. Enter username: `devops-deployer`
5. Click **Next**
6. Select **Attach policies directly**
7. Search for and select these policies:
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
   - `IAMFullAccess`
   - `AmazonSSMFullAccess`
8. Click **Create user**

### Step 1.2: Generate Access Keys

1. Click on the new `devops-deployer` user
2. Go to **Security credentials** tab
3. Scroll to "Access keys" → **Create access key**
4. Select "Command Line Interface (CLI)"
5. Check the confirmation box
6. Click **Create access key**
7. **Important**: Click **Download .csv file** and save it securely
   - Format: `AccessKeyId`, `SecretAccessKey`
   - **Keep this file safe!** You cannot retrieve it again.

**Example CSV contents:**
```
User name,Access key ID,Secret access key
devops-deployer,AKIAIOSFODNN7EXAMPLE,wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### Step 1.3: Configure AWS Credentials Locally

#### On Windows (PowerShell):

```powershell
# Navigate to workspace
cd C:\Users\<YourUsername>\Desktop\micro\devops-platform

# Configure AWS CLI with your credentials
aws configure

# You'll be prompted for:
# AWS Access Key ID: [paste from CSV]
# AWS Secret Access Key: [paste from CSV]
# Default region name: us-east-1
# Default output format: json
```

#### On macOS/Linux:

```bash
cd ~/Desktop/micro/devops-platform
aws configure

# AWS Access Key ID: [paste from CSV]
# AWS Secret Access Key: [paste from CSV]
# Default region name: us-east-1
# Default output format: json
```

### Step 1.4: Verify AWS Credentials

```bash
# Test AWS CLI connection
aws ec2 describe-regions

# Expected output: List of AWS regions
# If successful, you see a JSON response with regions
# If error: Check credentials in ~/.aws/credentials or %USERPROFILE%\.aws\credentials
```

---

## Phase 2: Prepare Local Environment

### Step 2.1: Install Required Tools

#### On Windows:

```powershell
# Using Chocolatey (if installed)
choco install terraform awscli ansible

# Or manual installation:

# 1. Git: https://git-scm.com/download/win
# 2. Terraform: https://www.terraform.io/downloads.html
# 3. AWS CLI: https://awscli.amazonaws.com/AWSCLIV2.msi
# 4. Ansible: pip install ansible
#    (Note: Windows users might prefer using WSL2)
```

#### On macOS:

```bash
# Using Homebrew
brew install terraform awscli ansible git

# Verify installations
terraform --version
aws --version
ansible --version
```

#### On Linux (Ubuntu/Debian):

```bash
sudo apt-get update
sudo apt-get install -y terraform awscli ansible git

# Verify installations
terraform --version
aws --version
ansible --version
```

### Step 2.2: Clone/Navigate to Project

```bash
# Navigate to your devops-platform directory
cd ~/Desktop/micro/devops-platform

# Verify structure
ls -la

# Expected output:
# README.md
# docker-compose.yml
# ansible/
# apps/
# docs/
# jenkins/
# nginx/
# scripts/
# terraform/
```

### Step 2.3: Create SSH Key Pair for AWS

```bash
# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Generate SSH key pair for AWS (on Linux/macOS)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-devops-key -N ""

# On Windows PowerShell:
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\aws-devops-key -N ""

# Verify keys were created
ls -la ~/.ssh/aws-devops-key*

# Output should show:
# aws-devops-key (private key)
# aws-devops-key.pub (public key)
```

### Step 2.4: Terraform Variables File

Create/verify `terraform/terraform.tfvars` file:

```hcl
# terraform/terraform.tfvars
project_name       = "devops-platform"
environment         = "production"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
instance_type       = "t2.micro"
instance_count      = 1
region              = "us-east-1"
availability_zone   = "us-east-1a"
enable_dns_hostnames = true

# SSH Configuration
ssh_public_key = file("~/.ssh/aws-devops-key.pub")

tags = {
  Project     = "DevOps Platform"
  Environment = "Production"
  CreatedDate = "2026-05-29"
  ManagedBy   = "Terraform"
}
```

---

## Phase 3: Deploy Infrastructure with Terraform

### Step 3.1: Initialize Terraform

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform (downloads providers, plugins)
terraform init

# Expected output:
# Terraform has been successfully configured!
# Working Directory: /path/to/devops-platform/terraform
```

### Step 3.2: Review Infrastructure Plan

```bash
# Create an execution plan (shows what will be created)
terraform plan -out=tfplan

# Expected output:
# Plan: 12 to add, 0 to change, 0 to destroy
# 
# Terraform will perform the following actions:
#   + aws_vpc.main
#   + aws_internet_gateway.main
#   + aws_subnet.public
#   + aws_route_table.public
#   + aws_security_group.main
#   + aws_instance.main
#   + aws_eip.main
#   ... and more

# Review the plan carefully! Do NOT proceed if something looks wrong.
```

### Step 3.3: Deploy Infrastructure

```bash
# Apply the Terraform plan (creates actual AWS resources)
terraform apply tfplan

# This will take 5-10 minutes
# Watch the output for the public IP address (you'll need this!)

# Expected output at end:
# Apply complete! Resources: 12 added, 0 destroyed.
# 
# Outputs:
# instance_id         = "i-0f3c1e2a3b4c5d6e7"
# instance_public_ip  = "54.123.456.789"
# key_pair_name       = "devops-platform-key"
# security_group_id   = "sg-0a1b2c3d4e5f6g7h8"
```

### Step 3.4: Save Output Values

```bash
# Export outputs to a file for reference
terraform output > ../outputs.txt

# Display outputs
terraform output

# Save these values! You'll need:
# - instance_public_ip (your server's address)
# - instance_id (AWS instance ID)
# - key_pair_name (for SSH access)
```

**⏰ At this point, your EC2 instance is spinning up and being initialized.**

---

## Phase 4: Configure Instances with Ansible

### Step 4.1: Wait for Instance to Boot

```bash
# EC2 instances take 2-3 minutes to fully boot and run user-data script
# You can check status in AWS Console:
# EC2 → Instances → Look for "running" status

# Or check via CLI:
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-platform-main" \
  --query 'Reservations[0].Instances[0].State.Name'

# Expected output: "running"

# Wait until Status Checks shows "2/2 checks passed"
# This takes approximately 5 minutes total
```

### Step 4.2: Update Ansible Inventory

Edit `ansible/inventory.ini`:

```ini
# ansible/inventory.ini
[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/aws-devops-key
ansible_python_interpreter=/usr/bin/python3

[webservers]
devops-main ansible_host=54.123.456.789  # Replace with your public IP

[docker_hosts]
devops-main ansible_host=54.123.456.789

[all]
devops-main ansible_host=54.123.456.789
```

### Step 4.3: Test Ansible Connectivity

```bash
# Navigate to Ansible directory
cd ../ansible

# Test connectivity to your instance
ansible all -i inventory.ini -m ping

# Expected output:
# devops-main | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }

# If you get connection errors:
# - Wait another 2-3 minutes for instance to fully boot
# - Verify the public IP is correct
# - Check security group allows port 22 (SSH)
```

### Step 4.4: Run Ansible Playbook

```bash
# Run the main playbook (installs Docker, Nginx, etc.)
ansible-playbook -i inventory.ini playbook.yml -v

# Expected output:
# PLAY [Configure all hosts] ***
# TASK [docker : Install Docker] ***
# ... (multiple tasks for each role)
# PLAY RECAP ***
# devops-main: ok=45 changed=23 unreachable=0 failed=0 skipped=2 rescued=0 ignored=0

# This will take 10-15 minutes to complete
# Watch for any "failed" tasks - if there are any, see troubleshooting
```

### Step 4.5: Verify Ansible Deployment

```bash
# SSH into your instance to verify
ssh -i ~/.ssh/aws-devops-key ec2-user@54.123.456.789

# Check Docker is installed and running
docker --version
sudo systemctl status docker

# Check Nginx
sudo systemctl status nginx

# Check Docker containers
sudo docker ps

# Exit SSH
exit
```

---

## Phase 5: Deploy Applications

### Step 5.1: Build and Deploy Containers

```bash
# SSH into your instance
ssh -i ~/.ssh/aws-devops-key ec2-user@54.123.456.789

# Navigate to app directory
cd /opt/apps  # (path configured by Ansible)

# Build Docker images
docker build -t portfolio-app ./portfolio
docker build -t weather-app ./weather-app
docker build -t tic-tac-toe-app ./tic-tac-toe
docker build -t stopwatch-app ./stopwatch

# Run containers
docker run -d -p 3001:80 --name portfolio portfolio-app
docker run -d -p 3002:80 --name weather weather-app
docker run -d -p 3003:80 --name tictactoe tic-tac-toe-app
docker run -d -p 3004:80 --name stopwatch stopwatch-app

# Verify containers are running
docker ps

# Output should show 4 running containers
```

### Step 5.2: Configure Nginx Routes

Nginx is configured to reverse proxy to these applications:

```
https://your-domain.com/portfolio  → :3001
https://your-domain.com/weather    → :3002
https://your-domain.com/tictactoe  → :3003
https://your-domain.com/stopwatch  → :3004
```

**Update Nginx config** (`nginx/default.conf`):

```bash
# On your instance
sudo nano /etc/nginx/sites-available/default

# Add these upstream blocks:
upstream portfolio {
    server localhost:3001;
}

upstream weather {
    server localhost:3002;
}

upstream tictactoe {
    server localhost:3003;
}

upstream stopwatch {
    server localhost:3004;
}

# Add location blocks in server:
location /portfolio {
    proxy_pass http://portfolio;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

location /weather {
    proxy_pass http://weather;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# (repeat for tictactoe and stopwatch)

# Reload Nginx
sudo systemctl reload nginx
```

### Step 5.3: Access Your Applications

Visit your instance's public IP in a browser:

```
http://54.123.456.789/portfolio
http://54.123.456.789/weather
http://54.123.456.789/tictactoe
http://54.123.456.789/stopwatch
```

---

## Phase 6: Verify Deployment

### Step 6.1: Health Checks

```bash
# SSH to instance
ssh -i ~/.ssh/aws-devops-key ec2-user@54.123.456.789

# Check system resources
free -h                 # Memory usage
df -h                   # Disk usage
top -b -n 1             # CPU and process info

# Check services status
sudo systemctl status docker
sudo systemctl status nginx

# Check running containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check logs
docker logs portfolio
docker logs weather-app
```

### Step 6.2: Network Connectivity Tests

```bash
# Test HTTP connectivity
curl http://54.123.456.789
curl http://54.123.456.789/portfolio
curl http://54.123.456.789/weather

# Test DNS (if you set up a domain)
nslookup yourdomain.com
```

### Step 6.3: Browser Verification

Open your browser and visit:

1. **Main Page**: `http://54.123.456.789`
   - Should show Nginx welcome page
   
2. **Portfolio App**: `http://54.123.456.789/portfolio`
   - Should load portfolio application
   
3. **Weather App**: `http://54.123.456.789/weather`
   - Should load weather application
   
4. **Tic-Tac-Toe**: `http://54.123.456.789/tictactoe`
   - Should load game
   
5. **Stopwatch**: `http://54.123.456.789/stopwatch`
   - Should load stopwatch

---

## Phase 7: Post-Deployment Configuration

### Step 7.1: Set Up SSL/HTTPS (Optional but Recommended)

```bash
# SSH to instance
ssh -i ~/.ssh/aws-devops-key ec2-user@54.123.456.789

# Install Certbot for Let's Encrypt
sudo yum install certbot python3-certbot-nginx -y

# Generate SSL certificate (replace with your domain)
sudo certbot certonly --nginx -d yourdomain.com

# Update Nginx to use SSL
sudo nano /etc/nginx/sites-available/default

# Add:
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    # ... rest of configuration
}

# Reload Nginx
sudo systemctl reload nginx
```

### Step 7.2: Enable Auto-SSL Renewal

```bash
# Enable auto-renewal for SSL certificates
sudo systemctl enable certbot-renew.timer
sudo systemctl start certbot-renew.timer

# Check renewal status
sudo systemctl status certbot-renew.timer
```

### Step 7.3: Configure Monitoring (Optional)

```bash
# Install CloudWatch agent for monitoring
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Configure to send metrics to CloudWatch
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

### Step 7.4: Set Up Automated Backups

```bash
# Create daily backup script
sudo nano /usr/local/bin/backup-docker-volumes.sh

# Add content:
#!/bin/bash
BACKUP_DIR="/home/ec2-user/backups"
mkdir -p $BACKUP_DIR
docker save $(docker images -q) | gzip > $BACKUP_DIR/docker-images-$(date +%Y%m%d).tar.gz
tar -czf $BACKUP_DIR/app-data-$(date +%Y%m%d).tar.gz /opt/apps

# Make executable
sudo chmod +x /usr/local/bin/backup-docker-volumes.sh

# Add to crontab for daily backup at 2 AM
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-docker-volumes.sh
```

---

## Troubleshooting

### Issue: "permission denied" when connecting with SSH

**Solution:**
```bash
# Fix SSH key permissions
chmod 600 ~/.ssh/aws-devops-key
chmod 700 ~/.ssh

# Try connecting again
ssh -i ~/.ssh/aws-devops-key ec2-user@54.123.456.789
```

### Issue: Ansible ping fails with "connection timeout"

**Cause**: Instance not fully booted or security group doesn't allow SSH

**Solution:**
```bash
# Wait 5-10 minutes for instance to fully boot
# Check instance status in AWS Console:
# EC2 → Instances → Check Status Checks (should be 2/2)

# Verify security group allows port 22:
aws ec2 describe-security-groups --group-ids sg-xxxxx

# Check if inbound rules include port 22
```

### Issue: Docker containers not running

**Solution:**
```bash
# Check Docker service
sudo systemctl status docker
sudo systemctl start docker

# Check container logs
docker logs container-name

# Restart containers
docker restart portfolio
docker restart weather-app
docker restart tic-tac-toe
docker restart stopwatch
```

### Issue: Nginx "502 Bad Gateway" error

**Cause**: Containers or Nginx reverse proxy configuration issue

**Solution:**
```bash
# Verify containers are running
docker ps

# Check Nginx configuration syntax
sudo nginx -t

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Reload Nginx
sudo systemctl reload nginx
```

### Issue: "Terraform apply" fails

**Solution:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# View detailed error
terraform apply -var-file="terraform.tfvars" -no-color

# Destroy and retry if needed
terraform destroy -auto-approve
terraform apply -var-file="terraform.tfvars"
```

### Issue: Running out of free tier limits

**Solution:**
```bash
# Check current usage
aws ce list-costs-by-resource

# Monitor in AWS Console:
# Billing → Cost Explorer → Filter by Free Tier

# Set billing alerts:
# Billing → Billing Preferences → Set alert threshold
```

---

## Cleanup & Cost Management

### Clean Up When Done (Avoid Charges!)

**⚠️ IMPORTANT**: Free Tier has limits! Destroy resources when not using.

```bash
# Navigate to Terraform directory
cd terraform

# View what will be destroyed
terraform plan -destroy

# Destroy all AWS resources
terraform destroy -auto-approve

# Expected output:
# Destroy complete! Resources: 12 destroyed.
```

### Cost Optimization Tips

1. **Use EC2 Scheduler** - Stop instance during non-working hours
   ```bash
   # Stop instance (no charges while stopped)
   aws ec2 stop-instances --instance-ids i-xxxxx
   
   # Start when needed
   aws ec2 start-instances --instance-ids i-xxxxx
   ```

2. **Set Billing Alerts**
   - Go to Billing → Billing Preferences
   - Set alert threshold to $5-10
   - Receive email alerts if exceeding

3. **Use Reserved Instances** (for long-term projects)
   - Saves ~30-40% on EC2 costs
   - Available after 12 months

4. **Monitor with CloudWatch**
   - Check EC2 CPU, memory, network usage
   - Identify unused resources

### Monitoring Dashboard

```bash
# View EC2 instance costs
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId, InstanceType, State.Name, LaunchTime]'

# View total account costs
aws ce get-cost-and-usage \
  --time-period Start=2026-05-01,End=2026-05-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

---

## Quick Reference Commands

### Terraform Commands
```bash
terraform init              # Initialize Terraform
terraform plan             # Preview changes
terraform apply            # Deploy infrastructure
terraform destroy          # Remove infrastructure
terraform output           # Show outputs
terraform state list       # List managed resources
```

### Ansible Commands
```bash
ansible all -i inventory.ini -m ping              # Test connectivity
ansible-playbook playbook.yml -i inventory.ini    # Run playbook
ansible all -i inventory.ini -m shell -a "command"  # Run shell command
```

### AWS CLI Commands
```bash
aws ec2 describe-instances                # List instances
aws ec2 start-instances --instance-ids ID  # Start instance
aws ec2 stop-instances --instance-ids ID   # Stop instance
aws ec2 terminate-instances --instance-ids ID  # Terminate instance
aws ec2 describe-security-groups           # List security groups
```

### SSH & Docker
```bash
ssh -i ~/.ssh/aws-devops-key ec2-user@IP         # SSH to instance
docker ps                                        # List running containers
docker logs container-name                       # View container logs
docker exec -it container bash                   # Shell into container
docker restart container-name                    # Restart container
```

---

## Summary Checklist

- [ ] AWS Account created and configured
- [ ] IAM user with access keys created
- [ ] Local tools installed (Terraform, Ansible, AWS CLI)
- [ ] AWS credentials configured
- [ ] SSH keys generated
- [ ] Terraform initialized and plan reviewed
- [ ] Infrastructure deployed with Terraform
- [ ] Instance fully booted (5+ minutes after deployment)
- [ ] Ansible connectivity verified
- [ ] Ansible playbook executed successfully
- [ ] Docker containers built and running
- [ ] Nginx configured and proxying correctly
- [ ] All applications accessible via browser
- [ ] SSL/HTTPS configured (optional)
- [ ] Monitoring and backups set up
- [ ] Billing alerts configured
- [ ] Documentation updated with your IPs/domains

---

## Next Steps

1. **Monitor Your Deployment**
   - Check CloudWatch dashboards
   - Review container logs regularly
   - Monitor costs

2. **Scale Up (If Needed)**
   - Add more EC2 instances
   - Use Auto Scaling Groups
   - Add load balancer

3. **Improve Security**
   - Implement WAF (Web Application Firewall)
   - Add VPN access
   - Set up SSO/authentication

4. **CI/CD Pipeline**
   - Configure Jenkins for auto-deployment
   - Set up GitHub webhooks
   - Implement automated testing

---

## Support & Resources

- **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest
- **Ansible Docs**: https://docs.ansible.com/
- **AWS Documentation**: https://docs.aws.amazon.com/
- **Docker Docs**: https://docs.docker.com/
- **Community Forums**: Stack Overflow, AWS Forums, Reddit r/aws

---

**Good luck with your deployment! 🚀**
