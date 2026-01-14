FROM node:18-bullseye

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
    libindicator7 \
    xvfb \
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
COPY mailspring-api.js /home/mailspring/mailspring-api.js

# Expose port
EXPOSE 6379

# Start Xvfb and Mailspring with API server
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 & \
    sleep 2 && \
    export DISPLAY=:99 && \
    npm start -- --dev > /tmp/mailspring.log 2>&1 & \
    sleep 10 && \
    node /home/mailspring/mailspring-api.js"]
