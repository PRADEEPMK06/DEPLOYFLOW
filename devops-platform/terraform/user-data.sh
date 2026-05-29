#!/bin/bash

# ============================================================================
# USER DATA SCRIPT FOR EC2 INSTANCE INITIALIZATION
# ============================================================================
# This script runs automatically when EC2 instance first starts.
#
# What does this script do?
# 1. Updates system packages
# 2. Installs Docker and Docker Compose
# 3. Installs Ansible
# 4. Installs other utilities
# 5. Creates necessary directories
# 6. Configures security settings
# 7. Sets up logging
#
# Execution:
# - Runs with root privileges
# - Runs only on first boot
# - Output logged to: /var/log/cloud-init-output.log
#
# Time to complete: 3-5 minutes depending on instance
#
# ============================================================================

set -e  # Exit if any command fails
set -x  # Print each command before executing

# ============================================================================
# LOGGING SETUP
# ============================================================================
# All output goes to both console and log file

LOGFILE="/var/log/devops-platform-init.log"
exec > >(tee -a $LOGFILE)
exec 2>&1

echo "=========================================="
echo "DevOps Platform - EC2 Initialization"
echo "Started at: $(date)"
echo "=========================================="

# ============================================================================
# SYSTEM UPDATES
# ============================================================================

echo "[1/8] Updating system packages..."
apt-get update -y
apt-get upgrade -y
apt-get install -y curl wget git vim software-properties-common

# ============================================================================
# DOCKER INSTALLATION
# ============================================================================
# Docker: Containerization platform for applications

echo "[2/8] Installing Docker..."

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add Docker repository
add-apt-repository -y \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
systemctl start docker
systemctl enable docker

# Verify Docker installation
docker --version
docker run hello-world || true

echo "Docker installed successfully"

# ============================================================================
# DOCKER COMPOSE INSTALLATION
# ============================================================================
# Docker Compose: Tool for managing multi-container applications

echo "[3/8] Installing Docker Compose..."

# Install Docker Compose (usually comes with Docker, but install separately to be sure)
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo "Docker Compose installed successfully"

# ============================================================================
# ANSIBLE INSTALLATION
# ============================================================================
# Ansible: Infrastructure automation tool

echo "[4/8] Installing Ansible..."

apt-get install -y ansible
ansible --version

echo "Ansible installed successfully"

# ============================================================================
# JENKINS INSTALLATION (OPTIONAL)
# ============================================================================
# Jenkins: CI/CD automation server
# Note: We can also install this via Ansible later

echo "[5/8] Installing Java (required for Jenkins)..."

apt-get install -y openjdk-17-jdk

# Verify Java
java -version

echo "Java installed successfully"

# ============================================================================
# NGINX INSTALLATION
# ============================================================================
# Nginx: Web server and reverse proxy

echo "[6/8] Installing Nginx..."

apt-get install -y nginx

# Start Nginx
systemctl start nginx
systemctl enable nginx

echo "Nginx installed successfully"

# ============================================================================
# ADDITIONAL UTILITIES
# ============================================================================

echo "[7/8] Installing additional utilities..."

# Useful tools
apt-get install -y \
  build-essential \
  python3-pip \
  python3-dev \
  htop \
  net-tools \
  tcpdump \
  unzip

# AWS CLI (for AWS operations from instance)
apt-get install -y awscli

echo "Additional utilities installed successfully"

# ============================================================================
# DIRECTORY SETUP
# ============================================================================

echo "[8/8] Setting up directories..."

# Create application directories
mkdir -p /opt/devops-platform
mkdir -p /opt/devops-platform/apps
mkdir -p /opt/devops-platform/configs
mkdir -p /opt/devops-platform/logs
mkdir -p /opt/devops-platform/data

# Create directory for Jenkins (if needed)
mkdir -p /var/lib/jenkins
mkdir -p /var/log/jenkins

# Set proper permissions
chmod -R 755 /opt/devops-platform
chmod -R 755 /var/lib/jenkins

echo "Directories created successfully"

# ============================================================================
# SECURITY HARDENING
# ============================================================================

echo "Applying security configurations..."

# UFW (Uncomplicated Firewall) - already handled by AWS Security Groups
# But we configure it for defense in depth

# Enable UFW (will be configured by Ansible)
# ufw enable -y  # Commented out - Ansible will handle this

# Update sudoers for Docker group (allow docker commands without sudo for ubuntu user)
usermod -aG docker ubuntu
usermod -aG docker root

# ============================================================================
# FINAL CHECKS
# ============================================================================

echo "Running final system checks..."

echo "Disk space:"
df -h

echo "Memory:"
free -h

echo "Installed versions:"
docker --version
docker-compose --version
ansible --version
nginx -v
java -version

# ============================================================================
# COMPLETION
# ============================================================================

echo "=========================================="
echo "EC2 Initialization Complete!"
echo "Completed at: $(date)"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. SSH into instance: ssh -i key.pem ubuntu@<public-ip>"
echo "2. Run Ansible playbooks"
echo "3. Deploy applications"
echo "4. Access applications at http://<public-ip>/app-name"
echo ""
echo "Log file: $LOGFILE"
echo ""

# ============================================================================
# END OF USER DATA SCRIPT
# ============================================================================
