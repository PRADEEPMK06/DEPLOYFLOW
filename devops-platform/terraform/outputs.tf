# ============================================================================
# TERRAFORM OUTPUTS
# ============================================================================
# This file defines output values that Terraform displays after apply.
#
# What are Outputs?
# - Values extracted from created resources
# - Displayed at end of terraform apply
# - Can be used by other tools/scripts
# - Useful for important information (IPs, URLs, etc.)
#
# Why outputs?
# - Users need the EC2 public IP to SSH and access apps
# - Important values in one place (not lost in state file)
# - Easy to copy-paste (IP address, SSH command, etc.)
#
# How to use outputs?
# - terraform output <output-name>
# - terraform output -json (JSON format for scripts)
#
# ============================================================================

# ============================================================================
# VPC AND NETWORKING OUTPUTS
# ============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id

  # Example output: vpc-0a1b2c3d4e5f6g7h8
  # Used for: Reference in other resources, documentation
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id

  # Example output: subnet-0x1y2z3a4b5c6d7e8
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id

  # Example output: sg-0abc1def2ghi3jkl4
}

# ============================================================================
# EC2 INSTANCE OUTPUTS
# ============================================================================

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id

  # Example output: i-0abc1def2ghi3jkl4
  # Used for: Managing instance through AWS CLI
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance (VPC internal)"
  value       = aws_instance.main.private_ip

  # Example output: 10.0.1.42
  # Internal to VPC, not accessible from internet
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (regular, may change)"
  value       = aws_instance.main.public_ip

  # Example output: 54.123.45.67
  # Accessible from internet
  # WARNING: Changes if instance stops/starts (use Elastic IP instead)
}

# ============================================================================
# ELASTIC IP OUTPUTS (RECOMMENDED FOR USE)
# ============================================================================

output "elastic_ip" {
  description = "Elastic IP address (static, does not change)"
  value       = aws_eip.main.public_ip

  # Example output: 54.123.45.67
  # IMPORTANT: Use this IP for applications, DNS records, bookmarks!
  # This IP does NOT change when instance stops/starts
  # Unlike regular public IP which changes on reboot
}

output "elastic_ip_allocation_id" {
  description = "Allocation ID of Elastic IP"
  value       = aws_eip.main.id

  # Example output: eipalloc-0abc1def2ghi3jkl4
  # Used in AWS CLI and API calls
}

# ============================================================================
# SSH ACCESS OUTPUTS
# ============================================================================

output "ssh_key_file" {
  description = "Path to SSH private key file"
  value       = local_file.private_key.filename

  # Example output: ./devops-platform-key.pem
  # This is the file you use to SSH into the instance
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${local_file.private_key.filename} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_eip.main.public_ip}"

  # Example output: ssh -i ./devops-platform-key.pem ubuntu@54.123.45.67
  # Copy-paste this command to connect to your instance
  # 
  # Flags explanation:
  # -i: Use specified private key file
  # -o StrictHostKeyChecking=no: Don't ask about host key
  # -o UserKnownHostsFile=/dev/null: Don't check known_hosts
  # ubuntu: Username (default for Ubuntu AMI)
  # 54.123.45.67: Public IP address
}

# ============================================================================
# APPLICATION ACCESS OUTPUTS
# ============================================================================

output "portfolio_url" {
  description = "URL to access Portfolio application"
  value       = "http://${aws_eip.main.public_ip}/portfolio"

  # After deploying, visit this URL in browser
  # Shows your portfolio application
}

output "weather_app_url" {
  description = "URL to access Weather application"
  value       = "http://${aws_eip.main.public_ip}/weather"
}

output "stopwatch_app_url" {
  description = "URL to access Stopwatch application"
  value       = "http://${aws_eip.main.public_ip}/stopwatch"
}

output "tic_tac_toe_url" {
  description = "URL to access Tic Tac Toe game"
  value       = "http://${aws_eip.main.public_ip}/game"
}

output "jenkins_url" {
  description = "URL to access Jenkins CI/CD dashboard"
  value       = "http://${aws_eip.main.public_ip}:8080"

  # Access Jenkins through Nginx proxy
  # After setup, visit this URL to configure pipelines
}

output "nginx_url" {
  description = "URL to Nginx home page (reverse proxy)"
  value       = "http://${aws_eip.main.public_ip}/"

  # Default Nginx page
  # All other routes proxy to applications
}

# ============================================================================
# IMPORTANT INFORMATION OUTPUT
# ============================================================================

output "all_information" {
  description = "Summary of all important information"
  value = {
    elastic_ip       = aws_eip.main.public_ip
    instance_id      = aws_instance.main.id
    ssh_key_file     = local_file.private_key.filename
    ssh_command      = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_eip.main.public_ip}"
    region           = var.aws_region
    availability_zone = var.availability_zone
    instance_type    = var.instance_type
    vpc_cidr          = var.vpc_cidr
    subnet_cidr       = var.public_subnet_cidr
  }

  # This groups all important info in one place
  # Useful for scripts or documentation
}

# ============================================================================
# AWS CLI COMMANDS OUTPUTS
# ============================================================================

output "aws_cli_describe_instance" {
  description = "AWS CLI command to describe the instance"
  value       = "aws ec2 describe-instances --instance-ids ${aws_instance.main.id} --region ${var.aws_region}"

  # Run this command to get detailed info about your instance
  # Useful for checking status, security groups, volumes, etc.
}

output "aws_cli_ssh_command" {
  description = "AWS Systems Manager Session Manager command to connect (alternative to SSH key)"
  value       = "aws ssm start-session --target ${aws_instance.main.id} --region ${var.aws_region}"

  # Alternative way to connect without SSH key
  # Requires EC2 instance profile with SSM role
}

# ============================================================================
# DEBUGGING OUTPUTS
# ============================================================================

output "debug_instance_state" {
  description = "Current state of the instance"
  value       = aws_instance.main.instance_state

  # Example: "running"
  # Possible states: pending, running, shutting-down, terminated, stopping, stopped
}

output "debug_security_group_rules" {
  description = "Security group configuration details"
  value = {
    group_id   = aws_security_group.main.id
    group_name = aws_security_group.main.name
    vpc_id     = aws_security_group.main.vpc_id
  }
}

# ============================================================================
# OUTPUT DISPLAY OPTIONS
# ============================================================================
# 
# After running 'terraform apply', you can view outputs with:
#
# 1. View all outputs:
#    terraform output
#
# 2. View specific output:
#    terraform output elastic_ip
#
# 3. Get outputs in JSON format (for scripts):
#    terraform output -json
#
# 4. Get specific output in JSON:
#    terraform output -json elastic_ip
#
# 5. Get raw value (without quotes):
#    terraform output -raw elastic_ip
#
# Example usage:
#   ELASTIC_IP=$(terraform output -raw elastic_ip)
#   ssh -i devops-platform-key.pem ubuntu@$ELASTIC_IP
#
# ============================================================================
