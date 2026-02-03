#!/bin/bash

# Uninstall script for SSH Agent Relay service

set -e

SERVICE_NAME="relay-ssh-agent@${USER}.service"
USER_SYSTEMD_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${USER_SYSTEMD_DIR}/relay-ssh-agent@.service"

echo "Uninstalling SSH Agent Relay service..."

# Stop the service if it's running
if systemctl --user is-active --quiet "${SERVICE_NAME}"; then
    echo "Stopping service..."
    systemctl --user stop "${SERVICE_NAME}"
fi

# Disable the service if it's enabled
if systemctl --user is-enabled --quiet "${SERVICE_NAME}" 2>/dev/null; then
    echo "Disabling service..."
    systemctl --user disable "${SERVICE_NAME}"
fi

# Remove the service file
if [ -f "${SERVICE_FILE}" ]; then
    echo "Removing service file..."
    rm -f "${SERVICE_FILE}"
fi

# Reload systemd daemon
echo "Reloading systemd daemon..."
systemctl --user daemon-reload

# Clean up the socket file
if [ -S "${HOME}/.ssh/agent.sock" ]; then
    echo "Removing socket file..."
    rm -f "${HOME}/.ssh/agent.sock"
fi

# Remove symlink to npiperelay.exe
if [ -L "${HOME}/.local/bin/npiperelay.exe" ]; then
    echo "Removing npiperelay.exe symlink..."
    rm -f "${HOME}/.local/bin/npiperelay.exe"
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "Remember to remove the following line from your ~/.bashrc or ~/.zshrc:"
echo "  export SSH_AUTH_SOCK=\$HOME/.ssh/agent.sock"
