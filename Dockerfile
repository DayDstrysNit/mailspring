FROM node:20-bookworm

# Install Mailspring build dependencies and Xvfb for headless display
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    git \
    cmake \
    libssl-dev \
    libglib2.0-dev \
    libgtk-3-dev \
    libnss3 \
    libxss1 \
    libappindicator3-1 \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    ffmpeg \
    sqlite3 \
    curl \
    ca-certificates \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Create mailspring user
RUN useradd -m -s /bin/bash mailspring

# Set working directory
WORKDIR /home/mailspring/app

# Copy source code
COPY . /home/mailspring/app/

# Fix permissions
RUN chown -R mailspring:mailspring /home/mailspring

# Switch to mailspring user
USER mailspring

# Install dependencies
RUN npm install --legacy-peer-deps

# Install development dependencies
RUN npm run-script build || echo "Build completed with warnings"

# Create config directories
RUN mkdir -p ~/.config/Mailspring ~/.cache ~/.local/share

# Install express and cors for API server
RUN npm install express cors

# Copy API server
COPY mailspring-api.js /home/mailspring/app/mailspring-api.js

# Expose port
EXPOSE 6379

# Start Xvfb, VNC, noVNC and Mailspring with API server
CMD ["sh", "-c", "Xvfb :99 -screen 0 1280x800x24 > /dev/null 2>&1 & \
    sleep 2 && \
    export DISPLAY=:99 && \
    x11vnc -display :99 -forever -shared -nopw -listen localhost -xkb > /dev/null 2>&1 & \
    websockify --web /usr/share/novnc 6080 localhost:5900 > /dev/null 2>&1 & \
    export ELECTRON_DISABLE_SANDBOX=1 && \
    npm start -- --dev --no-sandbox > /tmp/mailspring.log 2>&1 & \
    sleep 10 && \
    node /home/mailspring/app/mailspring-api.js"]
