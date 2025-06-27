# Set SSH Banner Script Documentation

## Overview
The `set-ssh-banner.sh` script configures a pre-login SSH banner for Alpine Linux (3.17+), displayed during SSH authentication. It supports custom messages and optional integration with tags from `set-motd.sh`.

## Purpose
This script is designed to:
- **Warn users**: Display a pre-login message (e.g., legal notice or system info) during SSH authentication.
- **Integrate with MOTD**: Optionally include tags from `/etc/motd-tags`.
- **Provide flexibility**: Allow enabling, customizing, or disabling the banner.
- **Enhance security**: Support security-by-obscurity when paired with a non-standard SSH port.

## Features
1. **Banner Content**:
   - Includes hostname, optional tags, and a default or custom message.
   - Stored in `/etc/ssh/banner`, displayed before login.

2. **Commands**:
   - `--message 'text'`: Sets a custom banner message.
   - `--include-tags`: Includes tags from `/etc/motd-tags`.
   - `--disable`: Disables the banner and removes `/etc/ssh/banner`.
   - (No args): Sets banner with default message ("Authorized users only. All activity is logged.").

3. **Configuration**:
   - Updates `/etc/ssh/sshd_config` with `Banner` directive.
   - Restarts SSH service to apply changes.

4. **Security**:
   - Validates `sshd` configuration before applying changes.
   - Sets banner file permissions to `644` (world-readable, root-writable).
   - Avoids sensitive information in the banner.

## Why It Does This
- **Security Awareness**: Warns users of monitoring or access restrictions before login.
- **System Identification**: Tags help identify server roles or environments.
- **Flexibility**: Allows standalone banner management, separate from MOTD.
- **Compliance**: Supports legal or organizational requirements for pre-login notices.

## Usage
```bash
chmod +x set-ssh-banner.sh
./set-ssh-banner.sh                            # Set default banner
./set-ssh-banner.sh --message "Welcome" --include-tags  # Custom message with tags
./set-ssh-banner.sh --disable                  # Disable banner
```

## Example Banner
```
/etc/ssh/banner:
Welcome to alpine-server
Tags: prod,web
Authorized users only. All activity is logged.
```

## Prerequisites
- Alpine Linux 3.17 or later.
- Root access to modify `/etc/ssh/sshd_config` and `/etc/ssh/banner`.
- `set-motd.sh` (optional) for tag integration.

## Security Considerations
- **Banner Content**: Avoid sensitive data (e.g., passwords, keys) in the banner.
- **Permissions**: Banner file is world-readable but only root-writable.
- **SSH Restart**: Validates configuration to prevent service disruption.

## Integration
To enable the banner during initial setup, add to `initial-setup.sh`:
```bash
./set-ssh-banner.sh --include-tags
```
Ensure `set-motd.sh` has run to populate `/etc/motd-tags` if tags are included.

## Future Improvements
- Support dynamic host info (e.g., IP or SSH port) in the banner.
- Add banner template configuration via a file.
- Support cross-distro compatibility (e.g., Ubuntu with `systemd`).
- Include SSH port (e.g., 2222) if changed for clarity.