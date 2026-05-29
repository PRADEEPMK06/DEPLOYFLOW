# DevOps Platform - Architecture Guide

## Complete System Architecture Explanation

> **Prerequisites**: Read [README.md](README.md) and [SETUP_GUIDE.md](setup-guide.md)  
> **Time to Read**: 20 minutes  
> **Difficulty**: Intermediate

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Data Flow](#data-flow)
3. [Component Details](#component-details)
4. [Networking](#networking)
5. [Security](#security)
6. [Scalability](#scalability)

---

## System Architecture

### High-Level Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                           INTERNET                                │
│                      (Users/Clients)                              │
└─────────────────────────────┬──────────────────────────────────┘
                              │
                    HTTP/HTTPS Port 80,443
                              │
    ┌─────────────────────────▼──────────────────────────────┐
    │                   AWS REGION: us-east-1                 │
    │                                                          │
    │  ┌──────────────────────────────────────────────────┐   │
    │  │        VPC: 10.0.0.0/16 (Isolated Network)     │   │
    │  │                                                  │   │
    │  │  ┌────────────────────────────────────────────┐ │   │
    │  │  │ Internet Gateway (IGW)                     │ │   │
    │  │  │ Purpose: Connect VPC to Internet           │ │   │
    │  │  └────────┬───────────────────────────────────┘ │   │
    │  │           │ Routes traffic between VPC & Internet
    │  │  ┌────────▼───────────────────────────────────┐ │   │
    │  │  │ Public Subnet: 10.0.1.0/24                │ │   │
    │  │  │ Availability Zone: us-east-1a             │ │   │
    │  │  │                                            │ │   │
    │  │  │  ┌──────────────────────────────────────┐ │ │   │
    │  │  │  │  EC2 Instance (t2.micro)             │ │ │   │
    │  │  │  │  Private IP: 10.0.1.x/32             │ │ │   │
    │  │  │  │  Public IP: 54.123.45.67 (Elastic)   │ │ │   │
    │  │  │  │  AMI: Ubuntu 24.04 LTS              │ │ │   │
    │  │  │  │                                      │ │ │   │
    │  │  │  │  ┌────────────────────────────────┐ │ │ │   │
    │  │  │  │  │ Docker & Applications          │ │ │ │   │
    │  │  │  │  │                                │ │ │ │   │
    │  │  │  │  │ ┌───────┐                      │ │ │ │   │
    │  │  │  │  │ │ NGINX │ (Port 80,443,8080)  │ │ │ │   │
    │  │  │  │  │ │ Rev.  │                      │ │ │ │   │
    │  │  │  │  │ │ Proxy │                      │ │ │ │   │
    │  │  │  │  │ └───┬─┬─┬───┘                  │ │ │ │   │
    │  │  │  │  │     │ │ │                      │ │ │ │   │
    │  │  │  │  │ ┌───▼┐│ │ ┌────┐               │ │ │ │   │
    │  │  │  │  │ │ P  ││ │ │ J  │               │ │ │ │   │
    │  │  │  │  │ │ O  ││W│S│ E  │               │ │ │ │   │
    │  │  │  │  │ │ R  ││ ││ │ N  │               │ │ │ │   │
    │  │  │  │  │ │ T  ││E││T│ K  │               │ │ │ │   │
    │  │  │  │  │ │ F  ││A││I│ I  │               │ │ │ │   │
    │  │  │  │  │ │ O  ││T││C│ N  │               │ │ │ │   │
    │  │  │  │  │ │ L  ││H││  │ S  │               │ │ │ │   │
    │  │  │  │  │ │ I  ││R││T│    │               │ │ │ │   │
    │  │  │  │  │ │ O  ││ ││A│    │               │ │ │ │   │
    │  │  │  │  │ └───┬┘ │ └┬───┬─┘               │ │ │ │   │
    │  │  │  │  │     │  │  │   │                │ │ │ │   │
    │  │  │  │  │  Docker Network (bridge)       │ │ │ │   │
    │  │  │  │  │                                │ │ │ │   │
    │  │  │  │  └────────────────────────────────┘ │ │ │   │
    │  │  │  │                                      │ │ │   │
    │  │  │  │  Security Group: Inbound Rules      │ │ │   │
    │  │  │  │  - Port 22:    SSH (0.0.0.0/0)    │ │ │   │
    │  │  │  │  - Port 80:    HTTP (0.0.0.0/0)   │ │ │   │
    │  │  │  │  - Port 443:   HTTPS (0.0.0.0/0)  │ │ │   │
    │  │  │  │  - Port 8080:  Jenkins (VPC only) │ │ │   │
    │  │  │  │                                      │ │ │   │
    │  │  │  └──────────────────────────────────────┘ │ │   │
    │  │  │                                            │ │   │
    │  │  └────────────────────────────────────────────┘ │   │
    │  │                                                  │   │
    │  └──────────────────────────────────────────────────┘   │
    │                                                          │
    └──────────────────────────────────────────────────────────┘
```

### Component Hierarchy

```
┌─────────────────────────────────────────────────┐
│ Level 1: Infrastructure (Terraform)             │
│ - AWS VPC, EC2, Security Groups, Key Pairs      │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│ Level 2: Configuration (Ansible)                │
│ - Install Docker, Nginx, dependencies           │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│ Level 3: Containerization (Docker Compose)      │
│ - Build images, networks, volumes               │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│ Level 4: Applications (Services)                │
│ - Portfolio, Weather, Stopwatch, Game, Jenkins  │
└─────────────────────────────────────────────────┘
```

---

## Data Flow

### Request Flow (User accesses /portfolio)

```
1. User Browser Request
   │
   ├─ HTTP GET http://54.123.45.67/portfolio
   │
2. Internet → AWS VPC (IGW)
   │
   ├─ Packet reaches VPC through Internet Gateway
   │
3. Route Table Decision
   │
   ├─ Route: 0.0.0.0/0 → IGW (internet traffic)
   ├─ Route: 10.0.0.0/16 → local (internal traffic)
   │
4. Security Group Check
   │
   ├─ Inbound: Port 80 from 0.0.0.0/0? ✓ ALLOWED
   ├─ Outbound: All traffic? ✓ ALLOWED
   │
5. EC2 Instance Receives Traffic
   │
   ├─ Destination: 10.0.1.x:80
   │
6. Nginx Reverse Proxy
   │
   ├─ Request: GET /portfolio
   ├─ Match location: /portfolio
   ├─ Rewrite: Remove /portfolio prefix
   ├─ Forward to: http://portfolio:80/
   │
7. Docker Network Resolution
   │
   ├─ DNS: portfolio → portfolio container IP
   │
8. Portfolio Container
   │
   ├─ Receives: GET / (rewritten request)
   ├─ Process: Serve HTML/CSS/JS
   ├─ Respond: 200 OK + HTML content
   │
9. Nginx Receives Response
   │
   ├─ Add headers: X-Forwarded-For, X-Real-IP, etc.
   ├─ Forward to client
   │
10. User's Browser
    │
    ├─ Receives: HTML, CSS, JavaScript
    ├─ Renders: Portfolio application
    ├─ Display: User sees portfolio page
```

### Architecture for Other Routes

| Route | Container | Port | Nginx Action |
|-------|-----------|------|--------------|
| `/portfolio` | portfolio | 80 | Remove prefix, proxy to container |
| `/weather` | weather-app | 80 | Remove prefix, proxy to container |
| `/stopwatch` | stopwatch | 80 | Remove prefix, proxy to container |
| `/game` | tic-tac-toe | 80 | Remove prefix, proxy to container |
| `:8080` | jenkins | 8080 | Proxy directly to Jenkins |

---

## Component Details

### 1. Infrastructure Layer (Terraform)

#### AWS VPC (Virtual Private Cloud)

```
VPC: 10.0.0.0/16
├── Public Subnet: 10.0.1.0/24
│   ├── EC2 Instance: 10.0.1.x
│   └── Associated with Internet Gateway
├── Internet Gateway
│   └── Routes external traffic
└── Route Table
    └── 0.0.0.0/0 → IGW (internet)
    └── 10.0.0.0/16 → local (internal)
```

**Why VPC?**
- Isolated network (no access from other AWS customers)
- Full control over networking
- Security (can restrict traffic)
- Multiple subnets (future expansion)

#### EC2 Instance

```
Instance: t2.micro (1 vCPU, 1 GB RAM)
├── OS: Ubuntu 24.04 LTS
├── Storage: 20 GB (gp3 volume)
├── Network: eth0 (10.0.1.x - private)
├── Public IP: 54.123.45.67 (Elastic)
├── Key Pair: devops-platform-key (SSH auth)
└── Security Group: devops-platform-sg
```

**Why t2.micro?**
- Free tier eligible (750 hours/month)
- Enough for learning and small-scale testing
- Burstable - can handle traffic spikes
- Cost: $0 within free tier

#### Security Group

```
Inbound Rules:
├── SSH (22) from 0.0.0.0/0
├── HTTP (80) from 0.0.0.0/0
├── HTTPS (443) from 0.0.0.0/0
└── Jenkins (8080) from VPC only

Outbound Rules:
└── All traffic to 0.0.0.0/0
```

**Why these rules?**
- SSH: Remote administration
- HTTP/HTTPS: Web traffic
- Jenkins: Internal only (security)
- Outbound: Download packages, API calls

### 2. Configuration Layer (Ansible)

**Tasks Executed:**
1. System updates
2. Docker installation
3. Nginx installation
4. Java installation (Jenkins)
5. Directory creation
6. User permissions

**Why Ansible?**
- Idempotent (safe to run multiple times)
- Agent-less (SSH only)
- YAML syntax (easy to read)
- Community support

### 3. Containerization Layer (Docker)

#### Docker Architecture

```
Host Machine (EC2)
├── Docker Daemon (running as service)
├── Docker Images (portfolio, weather, stopwatch, game, nginx)
├── Docker Network (devops-network bridge)
│   ├── Container: portfolio
│   ├── Container: weather-app
│   ├── Container: stopwatch
│   ├── Container: tic-tac-toe
│   ├── Container: nginx-reverse-proxy
│   └── Container: jenkins
└── Docker Volumes
    └── jenkins-data (persistent data)
```

#### Each Application Container

```
Container: portfolio
├── Image: nginx:latest (base)
├── Layer 1: Ubuntu base system
├── Layer 2: Nginx installed
├── Layer 3: Application files copied
├── Port: 80 (internal)
├── Network: devops-network
├── Resource Limits:
│   ├── CPU: 0.5 cores max
│   └── Memory: 256 MB max
└── Health Check: curl http://localhost/ every 30s
```

**Why Docker?**
- Lightweight (not full VM)
- Isolated (own filesystem, process space)
- Portable (same everywhere)
- Scalable (easy to replicate)

### 4. Application Layer (Services)

#### Nginx Reverse Proxy

```
Port 80 (external facing)
│
├─ Location: /portfolio
│  └─ Upstream: portfolio:80
│     └─ Action: Strip prefix, proxy
│
├─ Location: /weather
│  └─ Upstream: weather-app:80
│     └─ Action: Strip prefix, proxy
│
├─ Location: /stopwatch
│  └─ Upstream: stopwatch:80
│     └─ Action: Strip prefix, proxy
│
├─ Location: /game
│  └─ Upstream: tic-tac-toe:80
│     └─ Action: Strip prefix, proxy
│
├─ Location: /jenkins
│  └─ Upstream: jenkins:8080
│     └─ Action: WebSocket support, proxy
│
├─ Static Files
│  └─ Cache: 1 year (js, css, images)
│
└─ Security Headers
   ├─ X-Frame-Options: SAMEORIGIN
   ├─ X-Content-Type-Options: nosniff
   └─ CSP: Basic policy
```

**Why Nginx?**
- Lightweight and fast
- Reverse proxy (request distribution)
- Static file serving
- SSL/TLS termination ready
- Load balancing

#### Application Containers

Each application container:
- Same structure (Nginx + HTML/CSS/JS)
- Isolated environment
- Health checks
- Resource limits
- Consistent deployment

---

## Networking

### DNS Resolution (Docker Internal)

```
When portfolio container makes request to "weather-app":

1. Container: curl weather-app
2. Docker DNS (127.0.0.11:53)
3. Lookup: weather-app in devops-network
4. Result: weather-app → 172.18.0.x (container IP)
5. Route: Direct to container IP (bridge network)
```

### Port Mapping

```
External → Host → Container

http://user:80 → EC2:80 → nginx:80
                          ├─ /portfolio → portfolio:80
                          ├─ /weather → weather-app:80
                          ├─ /stopwatch → stopwatch:80
                          ├─ /game → tic-tac-toe:80
                          └─ :8080 → jenkins:8080
```

### Docker Network Bridge

```
Docker Network: devops-network (172.18.0.0/16)

Container IPs (assigned automatically):
├── nginx-reverse-proxy:     172.18.0.2
├── portfolio:               172.18.0.3
├── weather-app:             172.18.0.4
├── stopwatch:               172.18.0.5
├── tic-tac-toe:             172.18.0.6
└── jenkins:                 172.18.0.7

Communication:
- Containers can reach each other by name
- Nginx can proxy to "portfolio", "weather-app", etc.
- All on same bridge network
```

---

## Security

### Layered Security

```
Layer 1: AWS Security Group
├─ Port filtering
├─ Source IP restrictions
└─ Prevents unauthorized network access

Layer 2: Nginx Security Headers
├─ X-Frame-Options (clickjacking prevention)
├─ X-Content-Type-Options (MIME sniffing prevention)
├─ CSP (script injection prevention)
└─ Additional headers

Layer 3: Container Isolation
├─ Each app in separate container
├─ Own filesystem
├─ Own process space
├─ Resource limits
└─ Prevents lateral movement

Layer 4: Application Security
├─ HTTPS/SSL ready (add certificates)
├─ Regular updates (base images)
└─ Input validation (in applications)
```

### SSH Key Security

```
Private Key: devops-platform-key.pem (YOUR LOCAL COMPUTER)
├─ Never shared
├─ Never committed to Git
├─ Permissions: 0600 (read/write by owner only)
├─ Backup: Safe location
└─ Lost: Cannot recover without terminating instance

Public Key: Inside EC2 (~/.ssh/authorized_keys)
├─ Copied during provisioning
├─ Used to verify SSH connections
├─ Cannot be used alone to SSH
└─ Safe if leaked
```

### AWS IAM

```
IAM User: devops-user
├─ Access Key: Used with AWS CLI
├─ Secret Key: Like password (keep safe)
├─ Permissions: EC2, VPC, IAM (limited)
└─ Not root account (security best practice)
```

---

## Scalability

### Horizontal Scaling (Add more servers)

```
Current: 1 EC2 instance with all apps

Future: Multiple EC2 instances
├── Load Balancer (ALB/NLB)
├── Instance 1: Portfolio + Nginx + Jenkins
├── Instance 2: Weather + Nginx
└── Instance 3: Stopwatch + Tic-Tac-Toe + Nginx

Benefits:
✓ Higher availability
✓ Better performance
✓ Can survive server failure
✗ More complex (more resources)
✗ Increased costs
```

### Vertical Scaling (Bigger server)

```
Current: t2.micro (1 vCPU, 1 GB)

Upgrade: t2.small (1 vCPU, 2 GB)
or t2.medium (2 vCPU, 4 GB)

Benefits:
✓ Simple (just change instance_type)
✓ Less complex than horizontal
✗ Single point of failure
✗ Still not production-grade
```

### Container Scaling (Kubernetes)

```
Future: Use Kubernetes for orchestration
├── Automatic scaling (based on CPU/Memory)
├── Self-healing (restart failed containers)
├── Rolling updates (zero downtime deployments)
├── Multi-container deployment
└── Production-grade

Benefits:
✓ Enterprise-level reliability
✓ Automatic scaling
✓ Zero downtime updates
✗ More complex to learn
✗ More expensive
```

### Current Limits

**t2.micro with current setup:**
- ~1000-5000 concurrent users
- ~100-200 requests/second
- 1 GB memory limit
- Limited CPU bursts

**To handle more traffic:**
1. Upgrade to larger instance
2. Add more EC2 instances behind load balancer
3. Use Kubernetes for advanced orchestration
4. Add CDN for static content (CloudFront)
5. Add caching layer (Redis/Memcached)

---

## Performance Considerations

### Bottlenecks

1. **Network I/O**: Single public IP (no issue for learning)
2. **CPU**: 1 vCPU shared among services (burstable)
3. **Memory**: 1 GB total (tight with all services)
4. **Disk**: 20 GB (adequate for learning)

### Optimization Opportunities

1. **Nginx Caching**
   - Cache static files (already configured)
   - Reduce backend requests

2. **Container Limits**
   - Set appropriate CPU/Memory limits
   - Prevent one app from consuming all resources

3. **Docker Image Optimization**
   - Use smaller base images
   - Multi-stage builds
   - Remove unnecessary layers

4. **Database Caching**
   - Would apply if using backends
   - Redis for session storage
   - CDN for static content

---

## Monitoring & Logging

### Current Logging

```
Application Logs:
├── docker-compose logs -f                    # All services
├── docker-compose logs -f nginx              # Specific service
├── docker logs container-name -f              # Specific container
└── docker inspect container-name              # Container details

System Logs:
├── EC2: /var/log/cloud-init-output.log       # User data
├── Nginx: /var/log/nginx/access.log          # HTTP requests
├── Nginx: /var/log/nginx/error.log           # Nginx errors
├── Docker: Docker daemon logs (vary by OS)
└── Jenkins: /var/lib/jenkins/logs/

Terraform:
└── terraform.tfstate                         # Infrastructure state
```

### Future Monitoring

```
Recommended tools:
├── CloudWatch (AWS native)
├── Prometheus (metrics)
├── Grafana (visualization)
├── ELK Stack (logs: Elasticsearch, Logstash, Kibana)
└── Datadog (all-in-one)
```

---

## Summary

The DevOps Platform architecture is:

1. **Layered**: Infrastructure → Config → Containers → Apps
2. **Scalable**: Can grow horizontally or vertically
3. **Secure**: Multiple security layers
4. **Automated**: Terraform, Ansible, Docker, Jenkins
5. **Monitored**: Logging and health checks
6. **Professional**: Industry-standard practices

---

## Next Steps

1. ✅ Understand architecture
2. 📖 Read [Deployment Guide](deployment-guide.md) - Advanced topics
3. 🔧 Read [Troubleshooting Guide](troubleshooting.md) - Common issues
4. 💼 Prepare for [Interviews](interview-questions.md) - Technical questions

