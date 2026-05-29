# ============================================================================
# TERRAFORM PROVIDER CONFIGURATION
# ============================================================================
# This file configures the AWS provider and Terraform settings.
#
# What does this do?
# - Sets up the connection to AWS
# - Specifies AWS region
# - Configures required Terraform version
# - Sets up backend for state management (optional)
#
# IMPORTANT CONCEPTS:
# - Provider: Tells Terraform which cloud/service to use (AWS, Azure, GCP, etc.)
# - Region: The geographic location where resources will be created
# - State: Terraform stores infrastructure state in terraform.tfstate file
# ============================================================================

terraform {
  # Required Terraform version
  required_version = ">= 1.0"

  # Required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # OPTIONAL: Uncomment below to use S3 backend for remote state management
  # This is recommended for production/team environments
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "devops-platform/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }

  # For learning, we'll use local state (terraform.tfstate in your directory)
}

# ============================================================================
# AWS PROVIDER CONFIGURATION
# ============================================================================
# This section configures how Terraform connects to AWS

provider "aws" {
  region = var.aws_region

  # IMPORTANT: Make sure AWS credentials are configured:
  # 1. AWS CLI: aws configure
  # 2. Or set environment variables:
  #    - AWS_ACCESS_KEY_ID
  #    - AWS_SECRET_ACCESS_KEY
  # 3. Or use IAM roles on EC2

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "DevOps-Platform"
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# ============================================================================
# TERRAFORM STATE EXPLANATION
# ============================================================================
# 
# What is terraform.tfstate?
# - A JSON file that stores the current state of your infrastructure
# - Terraform uses it to know what resources exist
# - Never push this to GitHub! Add it to .gitignore
# - Contains sensitive information (keys, passwords, IPs, etc.)
#
# Local vs Remote State:
# Local: terraform.tfstate in your directory (good for learning)
# Remote: S3 backend (good for teams)
#
# terraform.tfstate.backup:
# - Terraform creates a backup of the previous state
# - Useful for recovery if something goes wrong
#
# State file locations after running terraform apply:
# - Local: ./terraform.tfstate
# - S3: In your bucket under the key specified
#
# IMPORTANT: In production, always use remote state with locking!
#
# ============================================================================
