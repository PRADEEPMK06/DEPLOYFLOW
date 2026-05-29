# ============================================================================
# TERRAFORM VARIABLES DEFINITION
# ============================================================================
# This file defines all input variables for the Terraform configuration.
#
# What is this?
# - Variables make your code reusable and flexible
# - Instead of hardcoding values, use variables
# - Can be overridden at runtime using -var flag or terraform.tfvars file
#
# Variable Types:
# - string: Text values
# - number: Numeric values
# - bool: true/false
# - list: Multiple values of same type
# - map: Key-value pairs
# - object: Complex structures
#
# ============================================================================

# ============================================================================
# AWS CONFIGURATION VARIABLES
# ============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  # Why us-east-1?
  # - Most free tier resources available
  # - Generally lowest latency for US users
  # - Most AWS features available first in us-east-1
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
}

# ============================================================================
# EC2 INSTANCE VARIABLES
# ============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"

  # Why t2.micro?
  # - Eligible for AWS Free Tier (1 year, 750 hours/month)
  # - Enough for learning and testing
  # - 1 GB RAM, 1 vCPU
  # - Can handle 4 simple web applications
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1

  # For now: 1 instance running all apps
  # In production: Multiple instances for high availability
}

variable "availability_zone" {
  description = "Availability zone for EC2 instance"
  type        = string
  default     = "us-east-1a"

  # Important: Must be in the same region as aws_region
  # Format: region + letter (a, b, c, d, etc.)
}

# ============================================================================
# VPC AND NETWORKING VARIABLES
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  # CIDR: Classless Inter-Domain Routing notation
  # 10.0.0.0/16 = VPC with IP range 10.0.0.0 to 10.0.255.255
  # 65,536 possible IP addresses in this VPC
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"

  # 10.0.1.0/24 = Subnet with IP range 10.0.1.0 to 10.0.1.255
  # 256 possible IP addresses in this subnet
  # Must be within VPC CIDR range
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true

  # Required for: EC2 instances, ECS, RDS
  # Allows instances to use friendly DNS names
}

# ============================================================================
# SECURITY GROUP VARIABLES
# ============================================================================

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  # SECURITY WARNING: This allows SSH from anywhere!
  # 0.0.0.0/0 = Allow from all IP addresses
  # 
  # In production, restrict to your IP:
  # default = ["203.0.113.42/32"]  (example: your office IP)
  # 
  # To find your IP:
  # - Google: "what is my ip"
  # - Command: curl https://checkip.amazonaws.com
}

variable "allowed_http_cidr" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  # Allow HTTP (port 80) from anywhere
  # This is necessary for web traffic
}

variable "allowed_https_cidr" {
  description = "CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  # Allow HTTPS (port 443) from anywhere
  # For SSL/TLS encrypted connections
}

variable "jenkins_port" {
  description = "Jenkins UI port"
  type        = number
  default     = 8080

  # Jenkins runs on port 8080 by default
  # We'll access it via Nginx proxy from port 80
}

# ============================================================================
# EC2 KEY PAIR VARIABLES
# ============================================================================

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "devops-platform-key"

  # This key pair is used to SSH into EC2 instances
  # Important: Store the private key safely!
}

variable "create_key_pair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = true

  # If true: Terraform creates key pair and saves private key
  # If false: Use existing key pair in AWS
}

# ============================================================================
# STORAGE AND ROOT VOLUME VARIABLES
# ============================================================================

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 20

  # Why 20 GB?
  # - Free tier includes 30 GB total
  # - 20 GB is enough for OS + Docker images + apps
  # - Leaves buffer for temporary files
}

variable "root_volume_type" {
  description = "Type of root volume"
  type        = string
  default     = "gp3"

  # gp3: General Purpose (good for most workloads)
  # gp2: Older generation (works but slower)
  # io1: High IOPS (expensive, not needed for this)
}

# ============================================================================
# AMI VARIABLES
# ============================================================================

variable "ami_owner" {
  description = "AMI owner (Canonical for Ubuntu)"
  type        = string
  default     = "099720109477"

  # 099720109477: Official Canonical Ubuntu AMI owner
  # Ensures you get official, updated Ubuntu images
}

variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "24.04"

  # 24.04: Latest Ubuntu LTS (Long Term Support)
  # LTS = Supported for 5 years
  # Non-LTS = Supported for 9 months
}

# ============================================================================
# ELASTIC IP VARIABLES
# ============================================================================

variable "associate_public_ip" {
  description = "Associate Elastic IP with EC2 instance"
  type        = bool
  default     = true

  # Elastic IP: Static public IP address
  # Why needed?
  # - Public IP changes when instance stops/starts
  # - Elastic IP stays same even after restarts
  # - Important for DNS and firewall rules
}

# ============================================================================
# TAGS AND NAMING VARIABLES
# ============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "devops-platform"

  # Used to create descriptive resource names
  # Example: devops-platform-vpc, devops-platform-sg, etc.
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "DevOps-Platform"
    CostCenter = "Engineering"
  }

  # Tags help with:
  # - Cost allocation (which department pays)
  # - Resource organization
  # - Automation (e.g., start/stop instances by tag)
  # - Compliance tracking
}

# ============================================================================
# MONITORING AND ALERTS VARIABLES (OPTIONAL)
# ============================================================================

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false

  # Detailed monitoring costs money
  # For free tier, use basic monitoring
}

variable "enable_termination_protection" {
  description = "Enable termination protection for EC2"
  type        = bool
  default     = false

  # If true: Prevents accidental deletion of instance
  # Set to true for production instances!
}

# ============================================================================
