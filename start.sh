#!/bin/bash

# Cleanup
rm -f /tmp/.X99-lock

# Start Xvfb
Xvfb :99 -screen 0 1280x800x24 > /dev/null 2>&1 &
sleep 2

export DISPLAY=:99

# Start VNC
x11vnc -display :99 -forever -shared -nopw -xkb > /dev/null 2>&1 &

# Start noVNC
websockify --web /usr/share/novnc 6080 localhost:5900 > /dev/null 2>&1 &

# Start DBUS
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS

# Ensure keyring directory exists
mkdir -p "$HOME/.local/share/keyrings"

# Start a basic keyring (dummy for Linux)
# We don't use --unlock here because we'll let it create a default collection if needed
eval $(echo "" | gnome-keyring-daemon --start --components=secrets)
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

# Start Window Manager
openbox &

# Start Mailspring API
node /home/mailspring/app/mailspring-api.js &

# Force create a default keyring with no password
# This uses python to interact with Secret service directly
python3 <<EOF
import gi
gi.require_version('Secret', '1')
from gi.repository import Secret, GLib
try:
    # Use a dummy password (empty string) to create/unlock
    Secret.Collection.create_sync(None, "login", "login", Secret.CollectionCreateFlags.NONE, None)
    print("Default 'login' collection verified/created.")
except Exception as e:
    print(f"Keyring init note: {e}")
EOF

# Auto-unlocker: Wait for any keyring windows and clear them
(
    export DISPLAY=:99
    while true; do
        # Try different names for the keyring prompt
        for win in "Unlock Login Keyring" "Create Password" "New Keyring" "Authentication Required"; do
            WID=$(xdotool search --name "$win" 2>/dev/null)
            if [ ! -z "$WID" ]; then
                echo "Found keyring window: $win. Sending blank password..."
                xdotool key --window "$WID" Return
                sleep 0.5
                xdotool key --window "$WID" Return
            fi
        done
        sleep 1
    done
) &

# Start Mailspring
echo "Starting Mailspring..."
export ELECTRON_DISABLE_SANDBOX=1
export ELECTRON_ENABLE_STACK_DUMPING=1
export DESKTOP_SESSION=gnome # Tell Electron to use gnome-keyring/libsecret

# Run Mailspring directly (since we already have a dbus session)
npm start -- --dev --no-sandbox --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage
