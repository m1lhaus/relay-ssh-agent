#!/bin/bash

# Install script for SSH Agent Relay service

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="relay-ssh-agent@.service"
SERVICE_NAME="relay-ssh-agent@${USER}.service"
USER_SYSTEMD_DIR="${HOME}/.config/systemd/user"

echo "Installing SSH Agent Relay service..."

# Check if socat is installed
if ! command -v socat &> /dev/null; then
    echo "Error: socat is not installed."
    echo "Please install it with: sudo apt-get install socat"
    exit 1
fi

# Check if npiperelay.exe is available
NPIPERELAY_PATH=""
if command -v npiperelay.exe &> /dev/null; then
    NPIPERELAY_PATH=$(which npiperelay.exe)
else
    echo "Error: npiperelay.exe not found in PATH."
    echo "Please install npiperelay.exe and ensure it's accessible from WSL."
    echo "Download from: https://github.com/jstarks/npiperelay"
    exit 1
fi

echo "Found npiperelay.exe at: ${NPIPERELAY_PATH}"

# Create user bin directory if it doesn't exist
mkdir -p "${HOME}/.local/bin"

# Create symlink to npiperelay.exe in ~/.local/bin
if [ -L "${HOME}/.local/bin/npiperelay.exe" ]; then
    echo "Removing existing symlink..."
    rm -f "${HOME}/.local/bin/npiperelay.exe"
fi

echo "Creating symlink to npiperelay.exe in ~/.local/bin..."
ln -s "${NPIPERELAY_PATH}" "${HOME}/.local/bin/npiperelay.exe"

# Create systemd user directory if it doesn't exist
mkdir -p "${USER_SYSTEMD_DIR}"

# Copy service file to systemd user directory
echo "Copying service file to ${USER_SYSTEMD_DIR}/"
cp "${SCRIPT_DIR}/${SERVICE_FILE}" "${USER_SYSTEMD_DIR}/"

# Reload systemd daemon
echo "Reloading systemd daemon..."
systemctl --user daemon-reload

# Enable the service
echo "Enabling service..."
systemctl --user enable "${SERVICE_NAME}"

# Start the service
echo "Starting service..."
systemctl --user start "${SERVICE_NAME}"

# Check service status
echo ""
echo "Service status:"
systemctl --user status "${SERVICE_NAME}" --no-pager || true

echo ""
echo "Installation complete!"
echo ""
echo "To ensure the service starts automatically:"
echo "  sudo loginctl enable-linger ${USER}"
echo ""
echo "Add this to your ~/.bashrc or ~/.zshrc:"
echo "  export SSH_AUTH_SOCK=\$HOME/.ssh/agent.sock"
echo ""
echo "Useful commands:"
echo "  Status:  systemctl --user status ${SERVICE_NAME}"
echo "  Stop:    systemctl --user stop ${SERVICE_NAME}"
echo "  Start:   systemctl --user start ${SERVICE_NAME}"
echo "  Restart: systemctl --user restart ${SERVICE_NAME}"
echo "  Logs:    journalctl --user -u ${SERVICE_NAME} -f"
