# infrastructure
Automated infrastructure setup for server in cloud environment.

## Overview

This repository contains automated setup scripts for configuring a secure server infrastructure. The `setup.sh` orchestrator runs modular setup scripts to configure various aspects of your server.

## Prerequisites

- Root access to the server
- Ubuntu/Debian-based Linux distribution
- Bash shell

## Configuration

Create a `.env` file in the root directory with the required environment variables:

```bash
SSH_PORT=12345
```

## Usage

Run the setup orchestrator as root:

```bash
sudo ./setup.sh
```

The orchestrator will:
1. Load environment variables from `.env`
2. Execute all setup scripts in sequence
3. Track and report success/failure of each script
4. Provide a comprehensive summary

## Setup Scripts

### SSH Configuration (`scripts/ssh.sh`)

Configures SSH with a custom port for enhanced security:
- Validates and updates SSH port configuration
- Creates timestamped backups of `sshd_config`
- Configures UFW firewall rules (if available)
- Restarts SSH service
- Verifies the new configuration

**Important**: After running, test the new SSH port in a separate terminal before closing your current session.

## Adding New Setup Scripts

To add additional setup scripts:

1. Create a new script in the `scripts/` directory
2. Make it executable: `chmod +x scripts/your-script.sh`
3. Add the script call to `setup.sh`:
   ```bash
   run_setup_script "your-script.sh"
   ```

The orchestrator will automatically handle execution, error tracking, and reporting.

## Security Best Practices

- Always test SSH configuration changes in a new terminal before closing your current session
- Keep backups of configuration files (automatically created by scripts)
- Review firewall rules after setup
- Consider disabling port 22 after verifying the new SSH port works: `sudo ufw delete allow 22/tcp`

## Troubleshooting

If a setup script fails:
1. Check the error output for specific issues
2. Review the summary at the end of execution
3. Configuration backups are stored with timestamps (e.g., `/etc/ssh/sshd_config.backup.YYYYMMDD_HHMMSS`)
4. Scripts can be run individually from the `scripts/` directory if needed
