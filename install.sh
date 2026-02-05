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
    echo "socat is not installed. Installing now..."
    echo "You may be prompted for your sudo password."
    echo ""
    sudo apt-get update && sudo apt-get install -y socat
    if ! command -v socat &> /dev/null; then
        echo "Error: Failed to install socat."
        exit 1
    fi
    echo "socat installed successfully."
fi

# Check if npiperelay.exe is available
NPIPERELAY_PATH=$(whereis npiperelay.exe | grep -oE '/mnt/[^ ]+' | head -n1)
if [ -z "${NPIPERELAY_PATH}" ] || [ ! -f "${NPIPERELAY_PATH}" ]; then
    echo "Error: npiperelay.exe not found in Windows filesystem (/mnt/*)."
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

# Verify symlink is valid
if [ -L "${HOME}/.local/bin/npiperelay.exe" ] && [ -e "${HOME}/.local/bin/npiperelay.exe" ]; then
    echo "Symlink created successfully and is valid"
else
    echo "Error: Failed to create valid symlink to npiperelay.exe"
    exit 1
fi

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

# Update .bashrc with SSH_AUTH_SOCK export
BASHRC="${HOME}/.bashrc"
SSH_AUTH_EXPORT="export SSH_AUTH_SOCK=\$HOME/.ssh/agent.sock"

echo ""
if grep -q "export SSH_AUTH_SOCK" "${BASHRC}" 2>/dev/null; then
    echo "Warning: 'export SSH_AUTH_SOCK' already exists in ~/.bashrc"
    echo "Please verify it is set to: export SSH_AUTH_SOCK=\$HOME/.ssh/agent.sock"
else
    echo "Adding SSH_AUTH_SOCK export to ~/.bashrc..."
    echo "" >> "${BASHRC}"
    echo "# SSH Agent Relay" >> "${BASHRC}"
    echo "${SSH_AUTH_EXPORT}" >> "${BASHRC}"
    echo "Successfully added to ~/.bashrc"
    echo "Run 'source ~/.bashrc' or restart your shell to apply changes"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Useful commands:"
echo "  Status:  systemctl --user status ${SERVICE_NAME}"
echo "  Stop:    systemctl --user stop ${SERVICE_NAME}"
echo "  Start:   systemctl --user start ${SERVICE_NAME}"
echo "  Restart: systemctl --user restart ${SERVICE_NAME}"
echo "  Logs:    journalctl --user -u ${SERVICE_NAME} -f"
