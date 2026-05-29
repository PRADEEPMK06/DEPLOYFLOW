# ============================================================================
# DOCKERFILE FOR WEATHER APPLICATION
# ============================================================================
# This file defines how to build a Docker image for the Weather app.
#
# Weather App: Fetches weather data from API and displays it
# Languages: HTML, CSS, JavaScript
# Dependencies: Needs internet access for API calls
#
# ============================================================================

FROM nginx:latest

LABEL maintainer="DevOps Team"
LABEL version="1.0"
LABEL description="Weather Application - Real-time Weather Data Display"

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

COPY ./weather-app /usr/share/nginx/html/

# Weather app files:
# ├── index.html        (main page, contains API key placeholder)
# ├── styles.css        (styling for weather display)
# └── script.js         (JavaScript for API calls and dynamic display)

# ============================================================================
# NGINX CONFIGURATION FOR WEATHER APP
# ============================================================================

RUN cat > /etc/nginx/conf.d/weather.conf << 'EOF'
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Important: Allow external API calls (CORS headers)
    location /api {
        # This allows JavaScript to make API calls to external weather service
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    error_page 404 /index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
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
# docker build -t weather-app:latest .
# docker run -d --name weather-app -p 3002:80 weather-app:latest
# ============================================================================
