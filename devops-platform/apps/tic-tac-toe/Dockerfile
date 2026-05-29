# ============================================================================
# DOCKERFILE FOR TIC TAC TOE GAME
# ============================================================================
# This file defines how to build a Docker image for the Tic Tac Toe app.
#
# Tic Tac Toe: Game with game logic and UI
# Languages: HTML, CSS, JavaScript
# No external dependencies needed
#
# ============================================================================

FROM nginx:latest

LABEL maintainer="DevOps Team"
LABEL version="1.0"
LABEL description="Tic Tac Toe Game - Interactive Game Application"

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

COPY . /usr/share/nginx/html/

# Tic Tac Toe app files:
# ├── index.html    (game board and UI)
# ├── styles.css    (game styling)
# └── script.js     (game logic and interactions)

# ============================================================================
# NGINX CONFIGURATION FOR TIC TAC TOE
# ============================================================================

RUN cat > /etc/nginx/conf.d/game.conf << 'EOF'
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
# docker build -t tic-tac-toe:latest .
# docker run -d --name tic-tac-toe -p 3004:80 tic-tac-toe:latest
# ============================================================================
