# ============================================================================
# TERRAFORM MAIN CONFIGURATION - AWS INFRASTRUCTURE
# ============================================================================
# This file contains the actual infrastructure resources.
#
# What will be created:
# 1. VPC (Virtual Private Cloud) - isolated network
# 2. Internet Gateway - connects VPC to internet
# 3. Public Subnet - publicly accessible network segment
# 4. Route Table - defines network traffic rules
# 5. Security Group - firewall rules
# 6. EC2 Instance - virtual server
# 7. Key Pair - SSH authentication
# 8. Elastic IP - static public IP address
#
# Total Resources: ~10 resources
# Estimated Cost: FREE (within AWS Free Tier limits)
#
# ============================================================================

# ============================================================================
# 1. VPC - VIRTUAL PRIVATE CLOUD
# ============================================================================
# What is VPC?
# - Isolated virtual network in AWS
# - Controls IP range, subnets, routing, security
# - Like having your own private data center in AWS
# - Free to create multiple VPCs
#
# Why create custom VPC?
# - Full control over network architecture
# - Security: Restrict who can access resources
# - Multiple environments in same AWS account
#
# ============================================================================

resource "aws_vpc" "main" {
  # CIDR block: IP address range for entire VPC
  # 10.0.0.0/16 provides 65,536 IP addresses
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  # DNS support is required for:
  # - RDS (database)
  # - Internal service discovery
  # - EC2 to use friendly domain names

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ============================================================================
# 2. INTERNET GATEWAY
# ============================================================================
# What is Internet Gateway?
# - Connects VPC to the internet
# - Allows resources to send/receive traffic from internet
# - Enables public IP addresses to work
#
# Without IGW:
# - EC2 instances can't reach internet
# - Users can't access your web applications
#
# ============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ============================================================================
# 3. PUBLIC SUBNET
# ============================================================================
# What is a Subnet?
# - Subdivides VPC into smaller networks
# - Each subnet is in one Availability Zone (AZ)
# - Multiple subnets provide redundancy and organization
#
# Public vs Private Subnet?
# - Public: Accessible from internet (web servers, NAT gateways)
# - Private: NOT accessible from internet (databases, backend services)
#
# Our setup: 1 public subnet (simple for learning)
# Production setup: Multiple public + private subnets
#
# ============================================================================

resource "aws_subnet" "public" {
  # Which VPC this subnet belongs to
  vpc_id = aws_vpc.main.id

  # CIDR block: IP range for this subnet
  # 10.0.1.0/24 provides 256 IP addresses
  # Must be within VPC CIDR range (10.0.0.0/16)
  cidr_block = var.public_subnet_cidr

  # Availability Zone: Physical location of servers
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  # map_public_ip_on_launch:
  # - true: EC2 instances get public IP automatically
  # - false: Manual assignment needed
  # Set to true for ease of learning

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# ============================================================================
# 4. ROUTE TABLE
# ============================================================================
# What is Route Table?
# - Rules for network traffic
# - Decides where packets go based on destination IP
#
# Example routes:
# - 10.0.0.0/16 → local (within VPC)
# - 0.0.0.0/0 → Internet Gateway (to internet)
#
# Public Route Table:
# - Has route to Internet Gateway
# - Attached to "public" subnet
# - Makes subnet public
#
# ============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# ============================================================================
# 4b. ROUTE: DEFAULT ROUTE TO INTERNET GATEWAY
# ============================================================================
# What does this do?
# - Any traffic destined for 0.0.0.0/0 (anywhere on internet)
# - Gets sent to Internet Gateway
# - Internet Gateway forwards it to destination
# - Enables internet access from instances
#
# ============================================================================

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  # destination_cidr_block = "0.0.0.0/0"
  # Meaning: Route for all traffic not matching other routes
  # 0.0.0.0 = any destination
  # /0 = any port/protocol
}

# ============================================================================
# 4c. ROUTE TABLE ASSOCIATION
# ============================================================================
# What does this do?
# - Associates route table with subnet
# - Tells VPC: "Use these routing rules for this subnet"
# - Without this association, routes won't apply
#
# ============================================================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  # After this:
  # - Public subnet knows how to route to internet
  # - EC2 instances in subnet can reach internet
}

# ============================================================================
# 5. SECURITY GROUP
# ============================================================================
# What is Security Group?
# - Virtual firewall for EC2 instances
# - Controls inbound and outbound traffic
# - Rules based on protocol, port, and source IP
#
# Inbound rules (who can connect TO your server):
# - SSH (port 22): For remote access
# - HTTP (port 80): Web traffic
# - HTTPS (port 443): Encrypted web traffic
# - Jenkins (port 8080): CI/CD tool (internal)
#
# Outbound rules (where your server can connect):
# - All traffic allowed (default)
#
# Important: Security Groups are STATEFUL
# - If inbound rule allows traffic, response automatically allowed
#
# ============================================================================

resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = "Security group for DevOps Platform"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# ============================================================================
# 5b. INBOUND RULE: SSH (port 22)
# ============================================================================
# Why SSH?
# - Secure Shell protocol for remote access
# - Allows you to log into EC2 instance
# - Encrypted connection
# - Need this to run commands, install software, etc.
#
# Security consideration:
# - 0.0.0.0/0 means "allow from anywhere"
# - In production: Restrict to your IP (203.0.113.42/32)
#
# ============================================================================

resource "aws_security_group_rule" "ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidr
  security_group_id = aws_security_group.main.id

  description = "Allow SSH access"
}

# ============================================================================
# 5c. INBOUND RULE: HTTP (port 80)
# ============================================================================
# Why HTTP?
# - HyperText Transfer Protocol
# - Standard web traffic
# - Unencrypted (HTTP) - data visible in transit
# - Encrypted version is HTTPS (port 443)
#
# Port 80 → Nginx Reverse Proxy
# Nginx routes traffic to applications (portfolio, weather, stopwatch, game)
#
# ============================================================================

resource "aws_security_group_rule" "http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_http_cidr
  security_group_id = aws_security_group.main.id

  description = "Allow HTTP traffic"
}

# ============================================================================
# 5d. INBOUND RULE: HTTPS (port 443)
# ============================================================================
# Why HTTPS?
# - Secure version of HTTP
# - Encrypted communication
# - Required for production
# - We'll set this up later with SSL certificates
#
# ============================================================================

resource "aws_security_group_rule" "https_inbound" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_https_cidr
  security_group_id = aws_security_group.main.id

  description = "Allow HTTPS traffic"
}

# ============================================================================
# 5e. INBOUND RULE: JENKINS (port 8080)
# ============================================================================
# Why Jenkins on 8080?
# - Jenkins UI runs on port 8080
# - We'll access it through Nginx reverse proxy
# - Nginx on port 80 → forwards to Jenkins on 8080
# - Only allow from VPC (internal access)
#
# ============================================================================

resource "aws_security_group_rule" "jenkins_inbound" {
  type              = "ingress"
  from_port         = var.jenkins_port
  to_port           = var.jenkins_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]  # Only from within VPC
  security_group_id = aws_security_group.main.id

  description = "Allow Jenkins access from VPC"
}

# ============================================================================
# 5f. OUTBOUND RULE: ALL TRAFFIC
# ============================================================================
# Outbound rules (egress):
# - Allow instance to connect to external services
# - Needed for: Docker image download, package installation, etc.
# - Default: Allow all (doesn't need explicit rule)
# - But we'll make it explicit for clarity
#
# ============================================================================

resource "aws_security_group_rule" "all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # -1 means all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id

  description = "Allow all outbound traffic"
}

# ============================================================================
# 6. KEY PAIR FOR SSH ACCESS
# ============================================================================
# What is Key Pair?
# - Public/Private key cryptography
# - Private key: Kept secret, used to SSH into instances
# - Public key: Stored on EC2 instance
#
# How SSH with key pair works?
# 1. AWS generates key pair
# 2. Public key stored on EC2 instance (~/.ssh/authorized_keys)
# 3. You download private key and keep it safe
# 4. To SSH: ssh -i private-key.pem ec2-user@public-ip
# 5. Private key proves you own the instance
#
# Why key pairs instead of passwords?
# - Stronger security (2048+ bit encryption)
# - No one can brute-force guess the key
# - Certificates are industry standard
#
# ============================================================================

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096

  # Generates a 4096-bit RSA private key
  # Stronger than typical 2048-bit keys
}

resource "aws_key_pair" "main" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name = "${var.project_name}-key-pair"
  }
}

# ============================================================================
# 6b. SAVE PRIVATE KEY TO FILE
# ============================================================================
# Important: This saves private key to local file
# File name: devops-platform-key.pem
# Permissions: 0600 (read/write only by owner)
#
# SECURITY WARNING:
# - Never share this file
# - Never commit to GitHub
# - Store in safe location
# - Anyone with this file can SSH into your instance
#
# ============================================================================

resource "local_file" "private_key" {
  filename        = "${var.key_pair_name}.pem"
  content         = tls_private_key.main.private_key_pem
  file_permission = "0600"

  # After terraform apply, key file will be in working directory
  # Usage: ssh -i devops-platform-key.pem ubuntu@<public-ip>
}

# ============================================================================
# 7. EC2 INSTANCE
# ============================================================================
# What is EC2?
# - Elastic Compute Cloud
# - Virtual server (computer) in AWS
# - You can start, stop, reboot, terminate instances
# - Charged by the hour (or by the second for newer instances)
#
# Why t2.micro?
# - Free tier eligible (750 hours/month free)
# - 1 GB RAM, 1 vCPU
# - Enough to learn and run small apps
# - Perfect for this project
#
# Ubuntu 24.04 LTS?
# - Latest long-term support version
# - Stable, well-documented
# - 5 years of security updates
# - Community support
#
# ============================================================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]  # Hardware Virtual Machine
  }

  # This finds the most recent Ubuntu AMI for the specified version
  # Ubuntu publishes new AMIs regularly with security patches
}

resource "aws_instance" "main" {
  # Which AMI (Amazon Machine Image) to use
  # AMI = pre-configured OS and software
  ami = data.aws_ami.ubuntu.id

  # Instance type: t2.micro = 1 vCPU, 1 GB RAM
  instance_type = var.instance_type

  # Which key pair to use for SSH
  key_name = aws_key_pair.main.key_name

  # Which subnet to launch instance into
  subnet_id = aws_subnet.public.id

  # Which security group to attach
  vpc_security_group_ids = [aws_security_group.main.id]

  # Assign public IP address
  associate_public_ip_address = true

  # EBS (Elastic Block Store) volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true  # Delete volume when instance terminates

    # Why delete_on_termination = true?
    # - Saves storage costs
    # - Prevents orphaned volumes
    # - Use false only if you need data after termination
  }

  # User data script: Run when instance first starts
  # This is like "initial setup script"
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    region = var.aws_region
  }))

  # Termination protection: Prevent accidental deletion
  disable_api_termination = var.enable_termination_protection

  # CloudWatch detailed monitoring (costs extra, disabled for free tier)
  monitoring = var.enable_detailed_monitoring

  # Enable IMDSv2 (Instance Metadata Service v2) for security
  # This prevents certain attacks
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "${var.project_name}-instance"
  }

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# 8. ELASTIC IP
# ============================================================================
# What is Elastic IP?
# - Static public IP address
# - Doesn't change when instance stops/starts
# - Regular public IP changes on reboot
# - Free if associated with running instance
#
# When to use:
# - When you need consistent IP for DNS records
# - When you need IP for firewall rules
# - When IP must remain same across reboots
#
# ============================================================================

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  # depends_on must be used for EIP associated with instance in VPC
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-eip"
  }
}

# ============================================================================
# END OF MAIN.TF
# ============================================================================
# 
# Summary of what was created:
# 1. VPC with CIDR 10.0.0.0/16
# 2. Internet Gateway connected to VPC
# 3. Public subnet with CIDR 10.0.1.0/24
# 4. Route table routing 0.0.0.0/0 to IGW
# 5. Security group with rules for SSH, HTTP, HTTPS, Jenkins
# 6. SSH key pair for authentication
# 7. EC2 instance (t2.micro) with Ubuntu 24.04 LTS
# 8. Elastic IP for static public IP
#
# Total resources: 15+
# Estimated monthly cost: ~$0 (within free tier)
#
# Next steps:
# 1. Run: terraform init
# 2. Run: terraform plan
# 3. Run: terraform apply
# 4. SSH into instance: ssh -i devops-platform-key.pem ubuntu@<public-ip>
#
# ============================================================================
