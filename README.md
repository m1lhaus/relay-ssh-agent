# SSH Agent Relay for WSL

A systemd service to relay SSH agent requests from WSL to the Windows SSH agent using [npiperelay](https://github.com/jstarks/npiperelay). Installing it as a service enables proper startup order and lifecycle management.

With this relay in place, you don't need to start and unlock the WSL (Linux) SSH agent. Each time you run `ssh` from a WSL terminal or from a VSCode WSL remote session, it will automatically forward requests to the Windows SSH agent. 

## How It Works

The service uses `socat` to create a Unix socket at `$HOME/.ssh/agent.sock` and forwards all requests through `npiperelay.exe` to the Windows SSH agent pipe (`//./pipe/openssh-ssh-agent`).

Compared to [.bashrc solution](https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows/), the systemd service approach ensures:
- Proper startup order (after default.target)
- Automatic restart on failure
- Clean socket management
- Proper logging via journald

## Prerequisites

- WSL 2
- Windows SSH Agent running (with your keys loaded)
- `socat` (will be automatically installed by the install script if not already present)
- [npiperelay.exe](https://github.com/jstarks/npiperelay/releases) installed and accessible from WSL
  - **Easy install**: Run `download_npiperelay.bat` (included) from Windows to automatically download, install, and configure npiperelay
  - **Important**: Ensure npiperelay.exe is located on the Windows filesystem, since WSL can't run `.exe` files from its own filesystem.

## Installation

### Windows Setup (one-time)

1. Run the automated installer from Windows (PowerShell or Command Prompt):

```batch
download_npiperelay.bat
```

This will automatically download npiperelay, install it to `%LOCALAPPDATA%\npiperelay`, and add it to your PATH.

**Alternative manual installation:** Download [npiperelay.exe](https://github.com/jstarks/npiperelay/releases) and add it to your Windows PATH manually.

### WSL Setup

2. Run the install script:

```bash
chmod +x install.sh
./install.sh
```

The install script will:
- Automatically install `socat` if not already present (requires sudo password)
- Create symlinks and configure the systemd service
- Add `export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock` to your `~/.bashrc` if not already present

3. Reload your shell or run:

```bash
source ~/.bashrc
```

## Usage

The service runs automatically. To manage it:

```bash
# Check status
systemctl --user status relay-ssh-agent@$USER.service

# View logs
journalctl --user -u relay-ssh-agent@$USER.service -f

# Restart
systemctl --user restart relay-ssh-agent@$USER.service

# Stop
systemctl --user stop relay-ssh-agent@$USER.service

# Start
systemctl --user start relay-ssh-agent@$USER.service
```

## Uninstallation

Run the uninstall script:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

**Note:** You will need to manually remove the `export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock` line from your `~/.bashrc` if you no longer need it.
