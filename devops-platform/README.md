# DevOps Platform - Multi-Application Deployment on AWS

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-v1.0+-blue.svg)](https://www.terraform.io/)
[![Docker](https://img.shields.io/badge/docker-latest-blue.svg)](https://www.docker.com/)
[![Ansible](https://img.shields.io/badge/ansible-v2.10+-blue.svg)](https://www.ansible.com/)

> **Production-style, fully automated DevOps platform for deploying 4 frontend applications on AWS EC2 using Terraform, Ansible, Docker, Jenkins, and Nginx**

## 🎯 Overview

DevOps Platform demonstrates modern infrastructure-as-code practices by automating the complete deployment of 4 frontend applications on AWS. This project is:

- ✅ **Production-Ready**: Industry best practices
- ✅ **Fully Automated**: From infrastructure to application deployment
- ✅ **Beginner-Friendly**: Detailed documentation and explanations
- ✅ **Cost-Effective**: Uses AWS Free Tier (~$0/month)
- ✅ **Educational**: Perfect for learning DevOps

## 📦 What You Get

### Applications
1. **Portfolio** - Personal portfolio website
2. **Weather App** - Real-time weather data display
3. **Stopwatch** - Timer and stopwatch tool
4. **Tic Tac Toe** - Interactive game

### Infrastructure
- **AWS VPC**: Isolated network with public subnet
- **EC2 Instance**: t2.micro (1 vCPU, 1 GB RAM)
- **Security Group**: Configured firewall rules
- **Elastic IP**: Static public IP address
- **Internet Gateway**: Internet connectivity

### Tools & Technologies
- **Terraform**: Infrastructure as Code
- **Ansible**: Configuration Management
- **Docker**: Containerization
- **Docker Compose**: Multi-container orchestration
- **Nginx**: Reverse proxy and web server
- **Jenkins**: CI/CD automation
- **Git**: Version control

## 🚀 Quick Start

### Prerequisites
- AWS account (free tier eligible)
- Git, Terraform, AWS CLI, Ansible installed
- ~30 minutes

### 5-Minute Setup

```bash
# 1. Clone repository
git clone https://github.com/your-repo/devops-platform.git
cd devops-platform

# 2. Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply  # Takes ~3-5 minutes

# 3. Get EC2 IP and configure Ansible
ELASTIC_IP=$(terraform output -raw elastic_ip)
cd ../ansible
sed -i "s/REPLACE_WITH_EC2_PUBLIC_IP/$ELASTIC_IP/" inventory.ini

# 4. Configure servers
ansible-playbook -i inventory.ini playbook.yml  # Takes ~10 minutes

# 5. Access applications
echo "http://$ELASTIC_IP/portfolio"
echo "http://$ELASTIC_IP/weather"
echo "http://$ELASTIC_IP/stopwatch"
echo "http://$ELASTIC_IP/game"
```

## 📁 Project Structure

```
devops-platform/
├── terraform/                    # Infrastructure as Code
│   ├── provider.tf              # AWS provider configuration
│   ├── variables.tf             # Variable definitions
│   ├── main.tf                  # Resource definitions
│   ├── outputs.tf               # Output values
│   ├── terraform.tfvars         # Configuration values
│   └── user-data.sh             # EC2 initialization
│
├── ansible/                     # Configuration Management
│   ├── inventory.ini            # Host inventory
│   ├── ansible.cfg              # Ansible settings
│   ├── playbook.yml             # Main playbook
│   └── roles/
│       ├── docker/              # Docker installation
│       ├── nginx/               # Nginx configuration
│       └── deploy/              # Application deployment
│
├── apps/                        # Applications
│   ├── portfolio/               # Portfolio app
│   ├── weather-app/             # Weather app
│   ├── stopwatch/               # Stopwatch app
│   └── tic-tac-toe/            # Game app
│
├── nginx/                       # Reverse proxy config
│   └── default.conf
│
├── jenkins/                     # CI/CD pipeline
│   └── Jenkinsfile
│
├── docker-compose.yml           # Multi-container config
│
└── docs/                        # Documentation
    ├── README.md                # Project overview
    ├── setup-guide.md           # Step-by-step setup
    ├── architecture.md          # Architecture details
    ├── troubleshooting.md       # Common issues
    └── interview-questions.md   # Interview prep
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│              Internet Users                  │
└─────────────────────┬───────────────────────┘
                      │ HTTP Port 80
                      ↓
        ┌─────────────────────────────┐
        │    AWS VPC 10.0.0.0/16      │
        │  Public Subnet 10.0.1.0/24  │
        │                             │
        │  ┌──────────────────────┐   │
        │  │  EC2 Instance (t2)   │   │
        │  │  ├── Nginx (Port 80) │   │
        │  │  ├── Portfolio       │   │
        │  │  ├── Weather         │   │
        │  │  ├── Stopwatch       │   │
        │  │  ├── Game            │   │
        │  │  └── Jenkins         │   │
        │  └──────────────────────┘   │
        │                             │
        └─────────────────────────────┘

Nginx Routing:
/              → Welcome page
/portfolio     → Portfolio container
/weather       → Weather container
/stopwatch     → Stopwatch container
/game          → Game container
:8080          → Jenkins UI
```

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [setup-guide.md](docs/setup-guide.md) | Complete step-by-step setup instructions |
| [architecture.md](docs/architecture.md) | Detailed architecture explanation |
| [troubleshooting.md](docs/troubleshooting.md) | Common issues and solutions |
| [interview-questions.md](docs/interview-questions.md) | Interview prep with 30 Q&As |

## 🔧 Usage

### Terraform Commands
```bash
cd terraform

# Initialize working directory
terraform init

# Preview what will be created
terraform plan

# Create infrastructure
terraform apply

# Destroy infrastructure
terraform destroy

# View outputs
terraform output
```

### Ansible Commands
```bash
cd ansible

# Test connectivity
ansible all -i inventory.ini -m ping

# Run playbook
ansible-playbook -i inventory.ini playbook.yml

# Run specific role
ansible-playbook -i inventory.ini playbook.yml --tags "docker"

# Dry-run mode
ansible-playbook -i inventory.ini playbook.yml --check
```

### Docker Commands
```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Execute command in container
docker-compose exec service-name bash
```

## 💻 System Requirements

### Local Machine
- 4 GB RAM minimum
- 10 GB free disk space
- Windows/Mac/Linux
- Internet connection

### AWS Free Tier
- t2.micro: 1 vCPU, 1 GB RAM ✅
- 30 GB storage ✅
- 750 hours/month ✅
- **Estimated Cost: $0 within free tier**

## 🔐 Security Considerations

### ⚠️ Important

1. **SSH Key**: `devops-platform-key.pem`
   - Store safely (not in Git)
   - Never share with anyone
   - Backup to secure location

2. **AWS Credentials**
   - Use IAM user (not root)
   - Use access keys (not passwords)
   - Rotate credentials regularly
   - Add to `.gitignore`

3. **Production Deployment**
   - Use HTTPS/SSL (Let's Encrypt)
   - Restrict SSH to your IP (not 0.0.0.0/0)
   - Enable AWS CloudTrail
   - Use secrets manager for passwords
   - Regular backups

## 📊 Learning Outcomes

After completing this project, you'll understand:

- ☑️ Cloud infrastructure (AWS concepts)
- ☑️ Infrastructure as Code (Terraform)
- ☑️ Configuration management (Ansible)
- ☑️ Containerization (Docker, Docker Compose)
- ☑️ Reverse proxy (Nginx)
- ☑️ CI/CD pipelines (Jenkins)
- ☑️ DevOps workflows and best practices
- ☑️ Networking and security groups
- ☑️ SSH and key-based authentication
- ☑️ Production deployment patterns

## 🎓 Interview Preparation

This project is perfect for interviewing at:
- DevOps Engineer roles
- Cloud Engineer positions
- Site Reliability Engineer (SRE)
- Infrastructure Engineer

See [interview-questions.md](docs/interview-questions.md) for 30 common questions with detailed answers.

## 🐛 Troubleshooting

Common issues:
- **SSH connection refused**: EC2 needs 2-3 minutes to initialize
- **Ansible ping fails**: Check SSH key permissions (should be 0600)
- **Applications not accessible**: Verify security group allows port 80
- **Docker not found**: Run Ansible playbook to install

See [troubleshooting.md](docs/troubleshooting.md) for detailed solutions.

## 📈 Next Steps

1. ✅ Complete basic setup (follow setup-guide.md)
2. ✅ Access all 4 applications in browser
3. ✅ Explore the infrastructure and understand each component
4. ✅ Read architecture.md for deep dive
5. ✅ Configure Jenkins for CI/CD
6. ✅ Add SSL/HTTPS certificates
7. ✅ Implement monitoring and logging
8. ✅ Scale to multiple EC2 instances
9. ✅ Migrate to Kubernetes for production

## 💡 Tips

- **Documentation is your friend**: All files have extensive comments
- **Start with basics**: Understand each tool separately first
- **Test locally**: Use Docker locally before deploying to AWS
- **Monitor costs**: Set AWS billing alerts
- **Ask questions**: DevOps is all about learning
- **Keep notes**: Document what you learn

## 🤝 Contributing

Contributions welcome! Areas for improvement:
- Kubernetes deployment example
- Blue-Green deployment strategy
- Multi-region setup
- Database integration (RDS)
- CDN configuration (CloudFront)
- Monitoring setup (CloudWatch, Prometheus)

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- Inspired by real DevOps practices
- Uses official Docker, Terraform, Ansible, and AWS documentation
- Community support from open-source projects

## 📞 Support

**Stuck?** Follow this order:
1. Check [troubleshooting.md](docs/troubleshooting.md)
2. Review relevant documentation
3. Check logs: `docker-compose logs -f service-name`
4. Test connectivity: `ansible all -i inventory.ini -m ping`
5. Search AWS documentation
6. Ask on Stack Overflow with relevant tags

## 🚀 Ready to Start?

**Begin here**: [SETUP_GUIDE.md](docs/setup-guide.md)

```bash
# Get started in 45 minutes
cd devops-platform
cat docs/setup-guide.md
```

---

**Author**: DevOps Learning Project  
**Last Updated**: 2024  
**Status**: ✅ Complete and Production-Ready

