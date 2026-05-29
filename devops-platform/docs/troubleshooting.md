# DevOps Platform - Troubleshooting Guide

## Common Issues & Solutions

> **Use this guide when you encounter problems**  
> **Each section has a diagnostic checklist**

---

## Table of Contents

1. [General Troubleshooting Steps](#general-troubleshooting-steps)
2. [Terraform Issues](#terraform-issues)
3. [Ansible Issues](#ansible-issues)
4. [Docker Issues](#docker-issues)
5. [Nginx Issues](#nginx-issues)
6. [Application Access Issues](#application-access-issues)
7. [Jenkins Issues](#jenkins-issues)
8. [Performance Issues](#performance-issues)
9. [AWS Issues](#aws-issues)

---

## General Troubleshooting Steps

### Always Start Here

Before specific troubleshooting, do these general checks:

```bash
# 1. Check Internet Connection
ping 8.8.8.8

# 2. Check AWS Credentials
aws sts get-caller-identity

# 3. Check if EC2 instance exists
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,IP:PublicIpAddress}'

# 4. Check if you can SSH
ELASTIC_IP=$(cd terraform && terraform output -raw elastic_ip)
ssh -i terraform/devops-platform-key.pem -o ConnectTimeout=5 ubuntu@$ELASTIC_IP "echo Connection OK"

# 5. Check Terraform state
cd terraform
terraform plan -detailed-exitcode
# Exit codes: 0=no changes, 1=error, 2=pending changes
```

---

## Terraform Issues

### Issue 1: "terraform command not found"

**Problem**: Terraform not installed or not in PATH

**Solution**:
```bash
# Check if installed
terraform --version

# If not found, install from https://www.terraform.io/downloads.html

# On Windows with Chocolatey
choco install terraform

# Add to PATH if needed (Windows)
$env:PATH += ";C:\where\terraform\is\located"
```

---

### Issue 2: "Error: Invalid provider configuration"

**Problem**: AWS credentials not configured

**Solution**:
```bash
# Option 1: Configure AWS CLI
aws configure
# Enter:
# AWS Access Key ID: [your access key]
# AWS Secret Access Key: [your secret key]
# Default region: us-east-1

# Option 2: Set environment variables (Windows PowerShell)
$env:AWS_ACCESS_KEY_ID="your_access_key"
$env:AWS_SECRET_ACCESS_KEY="your_secret_key"
$env:AWS_DEFAULT_REGION="us-east-1"

# Verify configuration
aws sts get-caller-identity
```

---

### Issue 3: "terraform apply" hangs or times out

**Problem**: Slow internet or AWS latency

**Solution**:
```bash
# Increase timeout in provider.tf
# Add to aws provider block:
# max_retries = 3
# skip_credentials_validation = false

# Try again with verbose output
TF_LOG=DEBUG terraform apply

# Check AWS service status
# Go to: https://status.aws.amazon.com/
```

---

### Issue 4: "Key pair already exists"

**Problem**: SSH key was already created

**Solution**:
```bash
# Option 1: Use existing key
# Delete the terraform output and re-import:
aws ec2 import-key-pair --key-name devops-platform-key --public-key-material file://existing-key.pub

# Option 2: Create with different name
# Edit terraform.tfvars:
# key_pair_name = "devops-platform-key-v2"

# Run terraform apply again
terraform apply
```

---

### Issue 5: Terraform state file corrupted

**Problem**: terraform.tfstate file is corrupted or invalid JSON

**Solution**:
```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Refresh state from AWS
cd terraform
terraform refresh

# If that doesn't work, re-initialize
rm -rf .terraform terraform.tfstate*
terraform init
terraform plan
```

---

## Ansible Issues

### Issue 1: "Permission denied (publickey)"

**Problem**: SSH key permissions wrong or path incorrect

**Solution**:
```bash
# Check key permissions (should be 0600)
ls -la devops-platform-key.pem
# Output: -rw------- 1 user group

# Fix permissions if needed
chmod 600 devops-platform-key.pem

# Verify key is in correct location
file ansible/devops-platform-key.pem

# Test SSH directly
ssh -i ansible/devops-platform-key.pem ubuntu@<elastic_ip> "echo OK"
```

---

### Issue 2: "EC2 instance not fully initialized"

**Problem**: SSH connection refused (instance is starting)

**Solution**:
```bash
# Wait 3-5 minutes after terraform apply

# Check instance status in AWS
aws ec2 describe-instance-status --instance-ids <instance-id> --region us-east-1

# Try SSH with retry
for i in {1..30}; do
  if ssh -i ansible/devops-platform-key.pem -o StrictHostKeyChecking=no ubuntu@<elastic_ip> "echo OK"; then
    echo "Connection successful"
    break
  fi
  echo "Attempt $i: Waiting..."
  sleep 5
done
```

---

### Issue 3: "Ansible inventory parsing error"

**Problem**: Inventory file has syntax errors

**Solution**:
```bash
# Validate inventory
ansible-inventory -i inventory.ini --list

# Check format
cat inventory.ini
# Should look like:
# [devops_platform]
# ec2_instance ansible_host=54.123.45.67

# Verify variables section
ansible-inventory -i inventory.ini --host ec2_instance
```

---

### Issue 4: "SSH connection refused" on Ansible

**Problem**: Can SSH directly but Ansible fails

**Solution**:
```bash
# Test Ansible connectivity
ansible all -i inventory.ini -m ping -vvv

# Check Ansible SSH settings
cat ansible.cfg
# Should have:
# host_key_checking = False
# connection = smart

# Verify SSH command manually
ssh -v -i ansible/devops-platform-key.pem ubuntu@<elastic_ip>

# If manual works but Ansible fails:
# Update inventory.ini with full SSH settings:
# ec2_instance ansible_host=<IP> \
#   ansible_user=ubuntu \
#   ansible_ssh_private_key_file=./devops-platform-key.pem \
#   ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

---

### Issue 5: "Task failed" or role not found

**Problem**: Ansible playbook encounters error in task

**Solution**:
```bash
# Run with verbose output
ansible-playbook -i inventory.ini playbook.yml -vvv

# Run specific play only
ansible-playbook -i inventory.ini playbook.yml --tags "docker"

# Check if role path is correct
ls -la roles/
# Should show: docker/, nginx/, deploy/ directories

# Verify role syntax
ansible-playbook -i inventory.ini playbook.yml --syntax-check

# Run in check mode (dry-run)
ansible-playbook -i inventory.ini playbook.yml --check
```

---

## Docker Issues

### Issue 1: "Docker command not found"

**Problem**: Docker not installed or not in PATH

**Solution**:
```bash
# Check if installed
docker --version

# If not installed on EC2:
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# Verify
docker run hello-world
```

---

### Issue 2: "Cannot connect to Docker daemon"

**Problem**: Docker service not running or permissions issue

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check Docker service
sudo systemctl status docker

# Start Docker if stopped
sudo systemctl start docker

# Check user is in docker group
groups ubuntu

# If not, add user to docker group
sudo usermod -aG docker ubuntu

# Logout and login for group changes to take effect
exit
# SSH back in
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Test
docker ps
```

---

### Issue 3: "docker-compose: command not found"

**Problem**: Docker Compose not installed

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check if installed
docker-compose --version

# Install if missing
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker-compose --version
```

---

### Issue 4: "Insufficient disk space"

**Problem**: Docker images or containers consume all 20 GB

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check disk usage
df -h

# Check Docker space usage
du -sh /var/lib/docker/

# Clean up unused images
docker image prune -a -f

# Clean up unused volumes
docker volume prune -f

# Clean up unused containers
docker container prune -f

# Full cleanup (aggressive)
docker system prune -a --volumes -f
```

---

### Issue 5: Container fails to start

**Problem**: `docker-compose up` shows exited containers

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check status
cd /opt/devops-platform
docker-compose ps

# View container logs
docker-compose logs <container-name>

# View specific container logs with tail
docker-compose logs --tail=50 -f <container-name>

# Inspect container
docker inspect <container-name>

# Check if port is already in use
sudo netstat -tulpn | grep -E '80|8080|3000'

# Restart services
docker-compose restart

# Full rebuild
docker-compose down
docker-compose up -d --build
```

---

## Nginx Issues

### Issue 1: "502 Bad Gateway"

**Problem**: Nginx can't connect to backend services

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check if backend containers are running
docker-compose ps

# Test if backend is responding
docker exec nginx-reverse-proxy curl -s http://portfolio:80 | head

# Check Nginx config
docker exec nginx-reverse-proxy nginx -t

# Check Nginx logs
docker-compose logs -f nginx

# Common causes:
# 1. Backend container not running → restart: docker-compose restart portfolio
# 2. Wrong port → verify docker-compose.yml expose sections
# 3. Wrong container name → verify upstream in nginx config
```

---

### Issue 2: "Connection refused"

**Problem**: Can't connect to applications

**Solution**:
```bash
# Check if Nginx is running
docker ps | grep nginx

# Check port 80 is listening
sudo netstat -tulpn | grep :80

# Check security group allows port 80
# AWS Console → EC2 → Security Groups → devops-platform-sg

# Test from EC2
curl http://localhost/portfolio

# Test from outside
curl http://<elastic_ip>/portfolio
```

---

### Issue 3: Application returns 404

**Problem**: Route exists but app not found

**Solution**:
```bash
# Check Nginx configuration
docker-compose exec nginx cat /etc/nginx/conf.d/default.conf

# Verify location blocks
grep "location" /etc/nginx/conf.d/default.conf

# Test Nginx location matching
curl -I http://localhost/portfolio/
curl -I http://localhost/portfolio/index.html
curl -I http://localhost/weather/

# Check backend is serving
docker exec portfolio nginx -t
docker exec portfolio curl http://localhost/

# Common issue: Path rewriting wrong
# Check rewrite rule matches request
```

---

## Application Access Issues

### Issue 1: "Can't access http://EC2_IP/portfolio"

**Problem**: Application not accessible from browser

**Diagnostic Checklist**:
```bash
# 1. Verify Elastic IP
cd terraform
terraform output -raw elastic_ip

# 2. Check EC2 is running
aws ec2 describe-instances --region us-east-1

# 3. Check security group allows port 80
aws ec2 describe-security-groups --region us-east-1 --query 'SecurityGroups[?GroupName==`devops-platform-sg`]'

# 4. Test from EC2 itself
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>
curl http://localhost/portfolio

# 5. Test from your local computer
# Open browser: http://<elastic_ip>/portfolio

# 6. If fails, try HTTP instead of HTTPS
# https:// won't work without SSL certificate

# 7. Check firewall (if behind corporate firewall)
# Try from different network (mobile hotspot)
```

**Solutions**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check containers
docker-compose ps

# Check Nginx
docker-compose logs nginx

# Restart all services
docker-compose restart

# Check logs
docker-compose logs -f

# View Nginx config
cat nginx/default.conf
```

---

### Issue 2: "Page loads but content looks broken"

**Problem**: HTML loads but CSS/JavaScript doesn't

**Solution**:
```bash
# Check browser console for errors
# In browser: F12 → Console tab

# Common causes:
# 1. Wrong path to CSS/JavaScript → check HTML file
# 2. Static files not served → check Nginx caching config
# 3. CORS issues → check Nginx headers

# Test from EC2
curl -v http://localhost/portfolio/ | grep -E "css|script"

# Check if files are in container
docker exec portfolio ls -la /usr/share/nginx/html/

# Verify file permissions
docker exec portfolio stat /usr/share/nginx/html/style.css
```

---

## Jenkins Issues

### Issue 1: "Can't access Jenkins at port 8080"

**Problem**: Jenkins UI not responding

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check if Jenkins container is running
docker ps | grep jenkins

# Check Jenkins logs
docker-compose logs -f jenkins

# Check if port 8080 is listening
sudo netstat -tulpn | grep 8080

# Restart Jenkins
docker-compose restart jenkins

# Wait for Jenkins to start (can take 60+ seconds)
sleep 60

# Check Jenkins again
curl -s http://localhost:8080 | head
```

---

### Issue 2: "Initial admin password not found"

**Problem**: Can't find Jenkins password on first setup

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Jenkins logs contain the password
docker-compose logs jenkins | grep "initial admin password" -A 1

# Or from Jenkins container directly
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

# If container doesn't exist or error occurs:
# 1. Check container is running: docker ps
# 2. Check logs: docker-compose logs jenkins
# 3. Restart: docker-compose restart jenkins
# 4. Wait a minute and try again
```

---

### Issue 3: "Jenkins not persisting data"

**Problem**: Settings lost after container restart

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check Jenkins volume
docker volume ls | grep jenkins

# Verify volume is mounted in container
docker inspect jenkins-server | grep -A 5 "Mounts"

# Should show jenkins-data volume mapped

# Check volume has data
sudo ls -la /var/lib/docker/volumes/jenkins-data/_data/

# If volume not persistent:
# 1. Check docker-compose.yml has volume definition
# 2. Verify volume name in docker-compose.yml: jenkins-data
# 3. Ensure volume is in volumes section
```

---

## Performance Issues

### Issue 1: "Applications are slow"

**Problem**: Pages take long to load

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check system resources
free -h              # Memory usage
df -h                # Disk usage
top -b -n 1          # CPU usage

# Check Docker resource limits
docker stats

# Check which container is using most resources
docker ps --format "table {{.Names}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Check if running out of memory
# If memory >90%, stop non-essential services

# Check network latency
curl -w "Time: %{time_total}s\n" http://localhost/portfolio

# Check Nginx response time
curl -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTotal: %{time_total}s\n" http://localhost/portfolio

# Optimize Docker Compose resources if needed
# Reduce resource limits in docker-compose.yml
```

---

### Issue 2: "Containers running out of memory"

**Problem**: "OOMKilled" or "out of memory" errors

**Solution**:
```bash
# SSH into EC2
ssh -i terraform/devops-platform-key.pem ubuntu@<elastic_ip>

# Check memory usage
free -h

# Check if containers are being killed
docker logs --tail=20 <container-name> | grep -i "oom\|memory"

# Check Docker events
docker events --filter type=container

# Stop non-essential services
docker-compose stop jenkins          # Frees ~200MB
docker-compose stop weather-app      # Try stopping apps individually

# Upgrade instance (if possible)
# Change instance_type in terraform.tfvars from t2.micro to t2.small
# Run: terraform apply

# Or reduce resource limits in docker-compose.yml
# Change from 256M to 128M per app
```

---

## AWS Issues

### Issue 1: "Elastic IP not associated"

**Problem**: IP address showing as not allocated

**Solution**:
```bash
# Check Elastic IP status
aws ec2 describe-addresses --region us-east-1

# Should show:
# "AssociationId": "eipassoc-xxx"
# "InstanceId": "i-xxx"
# "State": "associated"

# If not associated:
# 1. Check EC2 instance exists
# 2. Check instance is running (not stopped)
# 3. Re-run terraform apply
```

---

### Issue 2: "EC2 instance terminated unexpectedly"

**Problem**: Instance was terminated (can't access)

**Solution**:
```bash
# Check instance status
aws ec2 describe-instances --region us-east-1 --query 'Reservations[].Instances[].[InstanceId,State.Name]'

# If terminated:
# 1. Note the Instance ID for reference
# 2. Recreate with: terraform apply

# To prevent accidental termination:
# 1. Edit terraform.tfvars
# 2. Change: enable_termination_protection = true
# 3. Run: terraform apply

# Or in AWS Console:
# → EC2 → Instances → Right-click → Instance Settings → Change Termination Protection
```

---

### Issue 3: "Free Tier limit exceeded"

**Problem**: Getting charges for using resources

**Solution**:
```bash
# Check AWS Free Tier usage
# AWS Console → Billing → Free Tier

# For this project, costs should be:
# - EC2: 0 (750 hours/month)
# - EBS: 0 (30 GB/month)
# - Elastic IP: 0 (associated with running instance)

# If charged:
# 1. Stop instance: aws ec2 stop-instances --instance-ids <id>
# 2. Or destroy: terraform destroy
# 3. Check Elastic IPs aren't unassociated:
#    aws ec2 describe-addresses
# 4. Delete unassociated EIPs if charged

# Common issues:
# - Instance stopped but EIP not released (costs $3.50/month)
# - Extra EBS volume left behind
# - Previous instances not terminated
```

---

## Getting Help

### Before asking for help, provide:

```bash
# 1. Your error message (exact text)
# 2. What command you ran
# 3. Diagnostic output:

# Terraform state
terraform show

# Ansible hosts
ansible-inventory -i inventory.ini --list

# Docker status
docker-compose ps
docker-compose logs

# System info
aws ec2 describe-instances --region us-east-1
uname -a

# AWS CLI version
aws --version

# Tool versions
terraform --version
ansible --version
docker --version
```

### Resources

- Terraform Docs: https://www.terraform.io/docs/
- Ansible Docs: https://docs.ansible.com/
- Docker Docs: https://docs.docker.com/
- AWS Documentation: https://docs.aws.amazon.com/
- Stack Overflow: https://stackoverflow.com/ (tag your tools)

---

## Summary

Always follow this troubleshooting order:

1. **General checks**: Internet, AWS credentials, services running
2. **Tool-specific**: Terraform → Ansible → Docker → Nginx → Apps
3. **System checks**: Resources, logs, ports
4. **AWS checks**: Instance, security groups, quotas
5. **Search online**: Error message + tool name
6. **Ask for help**: Provide all diagnostic info

Most issues have simple solutions - **check logs first!**

