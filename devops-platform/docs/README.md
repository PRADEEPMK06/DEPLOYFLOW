# DevOps Platform - Project Overview

## 📚 Table of Contents

1. [Project Description](#project-description)
2. [Architecture Overview](#architecture-overview)
3. [Technologies Used](#technologies-used)
4. [Quick Start](#quick-start)
5. [Directory Structure](#directory-structure)
6. [Key Features](#key-features)
7. [Next Steps](#next-steps)

---

## Project Description

**DevOps Platform** is a production-style, multi-application deployment system that demonstrates industry-standard DevOps practices and tools.

### Problem It Solves

You have 4 separate frontend applications but no centralized way to deploy them. This project provides:

- Unified deployment platform for multiple applications
- Automated infrastructure provisioning
- CI/CD pipeline for continuous deployment
- Reverse proxy for routing traffic
- Professional DevOps workflows

### What This Project Includes

- **4 Frontend Applications** (Portfolio, Weather, Stopwatch, Tic Tac Toe)
- **AWS Infrastructure** (EC2, VPC, Security Groups)
- **Docker Containers** (One per application)
- **Nginx Reverse Proxy** (Route to applications)
- **Jenkins CI/CD** (Automated deployments)
- **Terraform** (Infrastructure as Code)
- **Ansible** (Configuration Management)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet Users                        │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/HTTPS (Port 80/443)
                         │
         ┌───────────────┴────────────────┐
         │   AWS VPC (10.0.0.0/16)        │
         │                                │
         │  ┌──────────────────────────┐  │
         │  │   Internet Gateway       │  │
         │  └──────────────┬───────────┘  │
         │                 │              │
         │  ┌──────────────▼───────────┐  │
         │  │   Public Subnet          │  │
         │  │   (10.0.1.0/24)          │  │
         │  │                          │  │
         │  │  ┌────────────────────┐  │  │
         │  │  │ EC2 Instance       │  │  │
         │  │  │ (t2.micro)         │  │  │
         │  │  │                    │  │  │
         │  │  │  ┌──────────────┐  │  │  │
         │  │  │  │ Nginx (80)   │  │  │  │
         │  │  │  │ Reverse      │  │  │  │
         │  │  │  │ Proxy        │  │  │  │
         │  │  │  └──┬─┬─┬─┬──────┘  │  │  │
         │  │  │     │ │ │ │         │  │  │
         │  │  │  ┌──▼┐│ │ │ ┌───┐  │  │  │
         │  │  │  │ P││ │ │ │ J │  │  │  │
         │  │  │  │ o││ │ │ │ e │  │  │  │
         │  │  │  │ r││W│S│T│n │  │  │  │
         │  │  │  │ t││e│t│i│k │  │  │  │
         │  │  │  │ f││a│o│c│i │  │  │  │
         │  │  │  │ o││t│p│T│n │  │  │  │
         │  │  │  │ l││h││a│s │  │  │  │
         │  │  │  │ i││e││c│(8 │  │  │  │
         │  │  │  │ o││r││T│0 │  │  │  │
         │  │  │  │   ││  ││8 │  │  │  │
         │  │  │  └───┘│  │└───┘  │  │  │
         │  │  │       │  │       │  │  │
         │  │  │  Docker Containers   │  │  │
         │  │  │                    │  │  │
         │  │  └────────────────────┘  │  │
         │  │                          │  │
         │  └──────────────────────────┘  │
         │                                │
         └────────────────────────────────┘
```

### Architecture Layers

| Layer | Component | Purpose |
|-------|-----------|---------|
| **Infrastructure** | Terraform | AWS resources (VPC, EC2, Security Groups) |
| **Server Config** | Ansible | Install Docker, Nginx, dependencies |
| **Containerization** | Docker | Package applications in containers |
| **Orchestration** | Docker Compose | Manage multiple containers |
| **Routing** | Nginx | Distribute traffic to applications |
| **CI/CD** | Jenkins | Automated building and deployment |

---

## Technologies Used

### Infrastructure & Provisioning
- **Terraform**: Infrastructure as Code (AWS resources)
- **AWS EC2**: Virtual servers
- **AWS VPC**: Networking

### Configuration Management
- **Ansible**: Server configuration automation
- **YAML**: Configuration language

### Containerization
- **Docker**: Container runtime
- **Docker Compose**: Multi-container orchestration

### Web Server & Reverse Proxy
- **Nginx**: Web server and reverse proxy

### CI/CD & Automation
- **Jenkins**: Continuous Integration/Deployment
- **Groovy**: Jenkins pipeline language

### Frontend Applications
- **HTML/CSS/JavaScript**: Frontend technologies

---

## Quick Start

### For Impatient Users (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/your-repo/devops-platform.git
cd devops-platform

# 2. Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# 3. Get EC2 public IP
ELASTIC_IP=$(terraform output -raw elastic_ip)
echo "EC2 IP: $ELASTIC_IP"

# 4. Configure Ansible
cd ../ansible
sed -i "s/REPLACE_WITH_EC2_PUBLIC_IP/$ELASTIC_IP/" inventory.ini

# 5. Run Ansible playbook
ansible-playbook -i inventory.ini playbook.yml

# 6. Access applications
echo "Applications are now accessible at:"
echo "Portfolio: http://$ELASTIC_IP/portfolio"
echo "Weather: http://$ELASTIC_IP/weather"
echo "Stopwatch: http://$ELASTIC_IP/stopwatch"
echo "Game: http://$ELASTIC_IP/game"
```

### For Detailed Setup

See [SETUP_GUIDE.md](docs/setup-guide.md) for step-by-step instructions.

---

## Directory Structure

```
devops-platform/
│
├── terraform/                 # Infrastructure as Code
│   ├── provider.tf           # AWS provider configuration
│   ├── variables.tf          # Variable definitions
│   ├── main.tf              # Main resource definitions
│   ├── outputs.tf           # Output values
│   ├── terraform.tfvars     # Variable values
│   └── user-data.sh         # EC2 initialization script
│
├── ansible/                   # Configuration Management
│   ├── inventory.ini        # Host inventory
│   ├── ansible.cfg          # Ansible configuration
│   ├── playbook.yml         # Main playbook
│   └── roles/
│       ├── docker/          # Docker installation role
│       ├── nginx/           # Nginx configuration role
│       └── deploy/          # Application deployment role
│
├── docker-compose.yml        # Multi-container configuration
│
├── nginx/                     # Reverse proxy configuration
│   └── default.conf         # Nginx configuration file
│
├── jenkins/                   # CI/CD pipeline
│   └── Jenkinsfile          # Jenkins pipeline definition
│
├── apps/                      # Applications
│   ├── portfolio/           # Portfolio app files + Dockerfile
│   ├── weather-app/         # Weather app files + Dockerfile
│   ├── stopwatch/           # Stopwatch app files + Dockerfile
│   └── tic-tac-toe/         # Game app files + Dockerfile
│
├── docs/                      # Documentation
│   ├── setup-guide.md       # Setup instructions
│   ├── architecture.md      # Architecture details
│   ├── deployment-guide.md  # Deployment process
│   ├── troubleshooting.md   # Common issues
│   └── interview-questions.md # Interview prep
│
└── scripts/                   # Utility scripts
    └── setup.sh             # Automated setup script
```

---

## Key Features

### ✅ Infrastructure as Code (Terraform)
- Automated AWS resource provisioning
- Reproducible deployments
- Version-controlled infrastructure
- Cost tracking through tags

### ✅ Configuration Management (Ansible)
- Automated server setup
- Idempotent operations (safe to run multiple times)
- Role-based organization
- Easy to understand YAML syntax

### ✅ Containerization (Docker)
- Lightweight, isolated environments
- Consistent across development and production
- Easy scaling and replication
- Resource limits and health checks

### ✅ Reverse Proxy (Nginx)
- Route multiple apps through single port
- Load balancing capabilities
- SSL/TLS termination ready
- Static file caching
- Security headers

### ✅ CI/CD Pipeline (Jenkins)
- Automated builds and deployments
- Test and verification stages
- Failure notifications
- Build history and reports
- Webhook integration

### ✅ Production-Ready
- Security best practices
- Health checks and monitoring
- Error handling and rollback capability
- Logging and troubleshooting
- Documentation and comments

---

## Next Steps

1. **Read Setup Guide**: [SETUP_GUIDE.md](docs/setup-guide.md)
   - Complete step-by-step instructions
   - Prerequisites and requirements
   - Command explanations

2. **Understand Architecture**: [ARCHITECTURE.md](docs/architecture.md)
   - Detailed architecture explanation
   - Data flow diagrams
   - Security considerations

3. **Deploy Locally**: Start with local deployment
   - Set up AWS account (if needed)
   - Install prerequisites
   - Run Terraform

4. **Configure Ansible**: Update inventory with your EC2 IP
   - Edit `ansible/inventory.ini`
   - Run playbook

5. **Access Applications**: Open in browser
   - http://your-ec2-ip/portfolio
   - http://your-ec2-ip/weather
   - http://your-ec2-ip/stopwatch
   - http://your-ec2-ip/game

6. **Set Up Jenkins**: Configure CI/CD
   - Access Jenkins UI
   - Configure credentials
   - Set up pipeline

7. **Troubleshooting**: Use guides
   - Check logs
   - Verify services
   - See troubleshooting guide

---

## Learning Outcomes

After completing this project, you will understand:

- **Cloud Infrastructure**: AWS resources, networking, security
- **Infrastructure as Code**: Terraform concepts and practices
- **Configuration Management**: Ansible for automation
- **Containerization**: Docker and orchestration
- **Reverse Proxying**: Nginx routing and load balancing
- **CI/CD**: Jenkins pipelines and automation
- **DevOps Workflow**: Complete deployment pipeline
- **Best Practices**: Production-ready configurations

---

## Support & Questions

For help:
1. Check [TROUBLESHOOTING.md](docs/troubleshooting.md)
2. Review log files in `/var/log/`
3. Check application health: `docker-compose ps`
4. View specific container logs: `docker-compose logs service-name`

---

## Next Document to Read

👉 **[SETUP_GUIDE.md](docs/setup-guide.md)** - Complete step-by-step setup instructions
