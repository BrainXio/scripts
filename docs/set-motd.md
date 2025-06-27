# Set MOTD Script Documentation

## Overview
The `set-motd.sh` script configures a unified Message of the Day (MOTD) for Alpine Linux (3.17+), displayed at login. It shows host information and manages a persistent list of configurable tags.

## Purpose
This script is designed to:
- **Inform users**: Display key system details (hostname, OS, IP, uptime) at login.
- **Tag systems**: Allow customizable tags for system identification (e.g., `prod`, `web`).
- **Ensure persistence**: Store tags in `/etc/motd-tags` for durability across reboots.
- **Simplify management**: Provide commands to add, remove, and list tags.

## Features
1. **Host Information**:
   - Hostname, OS version, primary non-loopback IP, uptime, and login time.
   - Written to `/etc/motd` for display at login.

2. **Tag Management**:
   - Stored in `/etc/motd-tags`, one per line.
   - Supports alphanumeric tags with hyphens/underscores.
   - Displayed as a comma-separated list in MOTD.

3. **Commands**:
   - `--add tag`: Adds a tag and updates MOTD.
   - `--remove tag`: Removes a tag and updates MOTD.
   - `--list-tags`: Lists current tags.
   - (No args): Updates MOTD with current info and tags.

4. **Security**:
   - Validates tag format to prevent invalid input.
   - Sets permissions (`644`) on MOTD and tags files for read-only access by non-root users.

## Why It Does This
- **User Awareness**: Provides critical system info for administrators at login.
- **System Organization**: Tags help identify server roles or environments.
- **Automation**: Persistent tags and scriptable commands support CI/CD workflows.
- **Consistency**: Ensures a standardized MOTD across servers.

## Usage
```bash
chmod +x set-motd.sh
./set-motd.sh              # Update MOTD
./set-motd.sh --add prod   # Add 'prod' tag
./set-motd.sh --remove prod # Remove 'prod' tag
./set-motd.sh --list-tags  # List tags
```

## Example MOTD
```
/etc/motd:
Welcome to alpine-server

System Information:
-------------------
OS: Alpine Linux v3.17
IP Address: 192.168.1.100
Uptime: 2 days, 3 hours, 15 minutes
Tags: prod,web,secure

Login time: Fri Jun 27 17:54:23 CEST 2025
-------------------
```

## Prerequisites
- Alpine Linux 3.17 or later.
- Root access to modify `/etc/motd` and `/etc/motd-tags`.
- `ip` command and `/etc/os-release` for system info.

## Security Considerations
- **Tag Validation**: Restricts tags to safe characters to prevent injection.
- **Permissions**: MOTD and tags files are world-readable but only root-writable.
- **No Sensitive Data**: Avoids exposing passwords or keys in MOTD.

## Integration
To set an initial MOTD during server setup, add to `initial-setup.sh`:
```bash
./set-motd.sh --add "newly-configured"
```

## Future Improvements
- Support key-value tags (e.g., `env=prod`).
- Allow custom MOTD templates via a config file.
- Add cross-distro compatibility for non-Alpine systems.
- Include SSH port in MOTD if changed (e.g., to 2222).