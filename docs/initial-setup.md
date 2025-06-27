# Initial Setup Script Documentation

## Overview
The `initial-setup.sh` script automates the creation of a secure, non-root administrative user on Ubuntu (20.04/22.04) and other systemd-based Linux distributions. It hardens SSH, enhances system security, and supports CI/CD automation with passwordless sudo.

## Purpose
This script is designed to:
- **Securely initialize servers**: Replace root access with a non-root sudo user for safer administration.
- **Harden SSH**: Disable insecure authentication methods and limit access.
- **Enhance system security**: Apply strict permissions, network protections, and intrusion detection.
- **Support CI/CD**: Enable passwordless sudo and non-interactive setup for automation.

## Features
1. **User Creation**:
   - Creates a new user with a validated username (lowercase, starts with letter).
   - Sets a secure password (interactive or via `CI_PASSWORD` environment variable).
   - Assigns `zsh` (if installed) or `bash` as the shell.
   - Adds user to `sudo` and `docker` groups.

2. **Passwordless Sudo**:
   - Configures `NOPASSWD:ALL` in `/etc/sudoers.d` for CI/CD automation.
   - Validates sudoers file for safety.

3. **SSH Setup**:
   - Copies root’s `authorized_keys` or uses `CI_SSH_KEY` for SSH access.
   - Sets strict permissions (`700` for `.ssh`, `600` for `authorized_keys`).

4. **SSH Hardening**:
   - Disables password authentication, root login, and PAM.
   - Limits SSH to the new user (`AllowUsers`).
   - Sets `MaxAuthTries` to 3 to deter brute-force attacks.
   - Removes cloud-init SSH overrides.

5. **Fail2ban**:
   - Installs and configures `fail2ban` to ban IPs after 3 failed SSH attempts (1-hour ban).

6. **System Security**:
   - Sets `umask 027` for stricter file permissions.
   - Applies sysctl settings to prevent IP spoofing, disable IP forwarding, and enable SYN cookies.
   - Persists sysctl configurations.

7. **Zsh Configuration**:
   - Creates a minimal `.zshrc` with history deduplication and no terminal bell.
   - Sets secure permissions (`600`).

8. **CI/CD Support**:
   - Accepts `CI_PASSWORD` and `CI_SSH_KEY` for non-interactive execution.
   - Ensures passwordless sudo for pipeline automation.

## Why It Does This
- **Security**: Root login and password-based SSH are common attack vectors. Disabling them reduces risk.
- **Privacy**: Strict file permissions and history deduplication protect user data.
- **Automation**: Passwordless sudo and environment variable support streamline CI/CD workflows.
- **Resilience**: Fail2ban and network protections mitigate brute-force and spoofing attacks.
- **Consistency**: Automated setup ensures uniform server configurations across deployments.

## Usage
```bash
chmod +x initial-setup.sh
sudo ./initial-setup.sh
```
- Interactive: Prompts for username and password.
- CI/CD: Set `CI_PASSWORD` and `CI_SSH_KEY` environment variables for non-interactive runs.

## Prerequisites
- Ubuntu 20.04/22.04 or compatible systemd-based Linux.
- Root or sudo access.
- Internet access for package installation.

## Security Considerations
- **Passwordless Sudo**: Convenient for CI/CD but risky if the user account is compromised. Consider limiting to specific commands.
- **SSH Keys**: Copying root’s keys is convenient but less secure than generating unique keys.
- **Fail2ban**: Adjust `bantime` or `maxretry` based on your threat model.

## Future Improvements
- Add UFW firewall to restrict inbound traffic.
- Generate unique SSH keys for the user.
- Enable `auditd` for system change tracking.
- Validate `docker` group existence before assignment.