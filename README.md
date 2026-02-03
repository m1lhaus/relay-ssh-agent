# SSH Agent Relay for WSL

A systemd service to relay SSH agent requests from WSL to the Windows SSH agent using [npiperelay](https://github.com/jstarks/npiperelay). Installing as service enables proper startup order and lifecycle management.

## Prerequisites

- WSL 2
- Windows SSH Agent running
- `socat` installed in WSL: `sudo apt-get install socat`
- [npiperelay.exe](https://github.com/jstarks/npiperelay/releases) installed and accessible from WSL

## Installation

1. Clone this repository
2. Run the install script:

```bash
chmod +x install.sh
./install.sh
```

3. Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
```

4. Reload your shell or run `source ~/.bashrc`

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

## How It Works

The service uses `socat` to create a Unix socket at `$HOME/.ssh/agent.sock` and forwards all requests through `npiperelay.exe` to the Windows SSH agent pipe (`//./pipe/openssh-ssh-agent`).

The systemd service ensures:
- Proper startup order (after network and multi-user targets)
- Automatic restart on failure
- Clean socket management
- Proper logging via journald
