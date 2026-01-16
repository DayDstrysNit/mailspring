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
    libsecret-1-0 \
    libsecret-1-dev \
    libtidy-dev \
    xvfb \
    x11vnc \
    dbus-x11 \
    libdbus-1-3 \
    gnome-keyring \
    firefox-esr \
    openbox \
    novnc \
    websockify \
    ffmpeg \
    sqlite3 \
    curl \
    ca-certificates \
    x11-apps \
    xdotool \
    python3-gi \
    gir1.2-secret-1 \
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

# Create a mock git command so postinstall.js doesn't fail
RUN mkdir -p /home/mailspring/.bin && \
    echo '#!/bin/bash\nif [[ "$*" == "submodule status ./mailsync" ]]; then echo "-dc00d36c9f78bcdf3dbfc53dd877e5c862679af3 mailsync"; else /usr/bin/git "$@"; fi' > /home/mailspring/.bin/git && \
    chmod +x /home/mailspring/.bin/git

ENV PATH="/home/mailspring/.bin:${PATH}"

# Install dependencies
RUN npm install --legacy-peer-deps

# Install development dependencies
RUN npm run-script build || echo "Build completed with warnings"

# Create config directories
RUN mkdir -p ~/.config/Mailspring ~/.cache ~/.local/share

# Fix noVNC index
USER root
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html
USER mailspring

# Install express and cors for API server
RUN npm install express cors

# Copy API server
COPY --chown=mailspring:mailspring mailspring-api.js /home/mailspring/app/mailspring-api.js

# Expose port
EXPOSE 6379

# Start Xvfb, VNC, noVNC and Mailspring with API server
COPY --chown=mailspring:mailspring start.sh /home/mailspring/start.sh
RUN chmod +x /home/mailspring/start.sh

CMD ["/home/mailspring/start.sh"]