# Set MOTD Script Documentation

## Overview
The `set-motd.sh` script configures a unified Message of the Day (MOTD) displayed at login, showing host information and managing a persistent list of configurable tags. It is designed for cross-distribution compatibility (Alpine, Ubuntu, Debian, CentOS, etc.).

## Purpose
This script is designed to:
- **Inform users**: Display key system details (hostname, OS, IP, uptime) at login.
- **Tag systems**: Allow customizable tags for system identification (e.g., `prod`, `web`).
- **Ensure persistence**: Store tags in `/etc/motd-tags` for durability across reboots.
- **Support portability**: Work across Linux distros with minimal dependencies.

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
- **Portability**: Works across Linux distributions without manual tweaks.

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
Welcome to server

System Information:
-------------------
OS: Alpine Linux v3.17
IP Address: 192.168.1.100
Uptime: 2 days, 3 hours
Tags: prod,web,secure

Login time: Fri Jun 27 18:07:23 CEST 2025
-------------------
```

## Prerequisites
- Linux distribution (e.g., Alpine 3.17+, Ubuntu, Debian, CentOS).
- Root access to modify `/etc/motd` and `/etc/motd-tags`.
- `grep`, `sed`, and either `ip` or `ifconfig` for system info.

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
- Handle additional system info (e.g., SSH port if changed).
- Add fallback for systems without `ip` or `ifconfig`.