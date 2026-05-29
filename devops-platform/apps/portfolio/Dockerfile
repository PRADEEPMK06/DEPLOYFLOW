# ============================================================================
# DOCKERFILE FOR PORTFOLIO APPLICATION
# ============================================================================
# This file defines how to build a Docker image for the Portfolio app.
#
# What is a Dockerfile?
# - Instructions to build a Docker image
# - Each line creates a layer in the image
# - Images are used to create containers
# - Containers run your application
#
# Docker building process:
# 1. Base image: nginx:latest (lightweight web server)
# 2. Copy files: Copy portfolio HTML, CSS, JS into image
# 3. Configure: Set up Nginx to serve the files
# 4. Build: docker build -t portfolio:latest .
# 5. Run: docker run -p 3001:80 portfolio:latest
#
# ============================================================================

# ============================================================================
# STAGE 1: BASE IMAGE
# ============================================================================
# Start from official Nginx image (lightweight, efficient)
# nginx:latest = Latest version of Nginx web server
# ~150 MB compressed image

FROM nginx:latest

# LABEL: Metadata about this image
LABEL maintainer="DevOps Team"
LABEL version="1.0"
LABEL description="Portfolio Application - Personal Portfolio Website"

# ============================================================================
# INSTALL DEPENDENCIES
# ============================================================================
# Update packages and install any needed tools

RUN apt-get update && \
    apt-get install -y curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Why clean up?
# - Reduces image size
# - Removes package cache (not needed in container)
# - Faster image pulls and deployments

# ============================================================================
# COPY APPLICATION FILES
# ============================================================================
# Copy portfolio files from host machine to container

# Copy HTML, CSS, JavaScript files to Nginx web root
COPY ./portfolio /usr/share/nginx/html/

# Directory structure:
# /usr/share/nginx/html/
# ├── index.html        (main page)
# ├── style.css         (styling)
# ├── styles.css        (additional styles)
# └── script.js         (JavaScript functionality)

# ============================================================================
# CONFIGURE NGINX
# ============================================================================
# Nginx configuration for serving static files

RUN mkdir -p /etc/nginx/conf.d/

# Create Nginx configuration
RUN cat > /etc/nginx/conf.d/portfolio.conf << 'EOF'
server {
    listen 80;
    server_name _;

    # Root directory for serving files
    root /usr/share/nginx/html;

    # Default file to serve
    index index.html;

    # Location for all requests
    location / {
        # Try to serve requested file
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Error pages
    error_page 404 /index.html;
}
EOF

# ============================================================================
# HEALTH CHECK
# ============================================================================
# Docker health check: Is the container running properly?

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# This command runs every 30 seconds
# If curl fails (exits with non-0), container marked as unhealthy
# Useful for Kubernetes, Docker orchestration

# ============================================================================
# EXPOSE PORT
# ============================================================================
# Tell Docker this container listens on port 80

EXPOSE 80

# Port 80: Standard HTTP port
# Note: This doesn't publish the port, just documents it
# Publishing happens in docker run or docker-compose

# ============================================================================
# START NGINX
# ============================================================================
# Default command when container starts

CMD ["nginx", "-g", "daemon off;"]

# nginx: Run Nginx server
# -g daemon off: Run in foreground (required for Docker)
#    Without this: Nginx daemonizes and container exits
#    Docker containers need foreground process

# ============================================================================
# DOCKERFILE BEST PRACTICES USED:
# ============================================================================
# 1. Used lightweight base image (nginx)
# 2. Combined RUN commands with && (fewer layers)
# 3. Cleaned up apt cache (smaller image)
# 4. Added labels for metadata
# 5. Included health check
# 6. Documented with comments
# 7. Used specific ports
# 8. Non-root process (nginx)
#
# ============================================================================
# BUILD COMMAND:
# docker build -t portfolio:latest .
#
# RUN COMMAND:
# docker run -d --name portfolio -p 3001:80 portfolio:latest
#
# VERIFY:
# docker ps
# curl http://localhost:3001
#
# ============================================================================
