# ============================================================================
# DOCKERFILE FOR STOPWATCH APPLICATION
# ============================================================================
# This file defines how to build a Docker image for the Stopwatch app.
#
# Stopwatch App: Timer/stopwatch functionality
# Languages: HTML, CSS, JavaScript
# No external dependencies needed
#
# ============================================================================

FROM nginx:latest

LABEL maintainer="DevOps Team"
LABEL version="1.0"
LABEL description="Stopwatch Application - Timer and Stopwatch Tool"

# ============================================================================
# INSTALL DEPENDENCIES
# ============================================================================

RUN apt-get update && \
    apt-get install -y curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ============================================================================
# COPY APPLICATION FILES
# ============================================================================

COPY ./stopwatch /usr/share/nginx/html/

# Stopwatch app files:
# ├── index.html    (main stopwatch interface)
# ├── styles.css    (styling for timer display)
# └── script.js     (JavaScript for timer logic)

# ============================================================================
# NGINX CONFIGURATION FOR STOPWATCH APP
# ============================================================================

RUN cat > /etc/nginx/conf.d/stopwatch.conf << 'EOF'
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    error_page 404 /index.html;
}
EOF

# ============================================================================
# HEALTH CHECK
# ============================================================================

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# ============================================================================
# EXPOSE AND START
# ============================================================================

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# ============================================================================
# BUILD AND RUN:
# docker build -t stopwatch:latest .
# docker run -d --name stopwatch -p 3003:80 stopwatch:latest
# ============================================================================
