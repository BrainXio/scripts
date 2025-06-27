# Initial Setup Script Documentation (Alpine Linux)

## Overview
The `initial-setup.sh` script automates the creation of a secure, non-root administrative user on Alpine Linux (3.17+). It hardens SSH, enhances system security, and supports CI/CD automation with passwordless `doas`.

## Purpose
This script is designed to:
- **Securely initialize servers**: Replace root access with a non-root user for safer administration.
- **Harden SSH**: Disable insecure authentication methods and limit access.
- **Enhance system security**: Apply strict permissions, network protections, and intrusion detection.
- **Support CI/CD**: Enable passwordless `doas` and non-interactive setup for automation.

## Features
1. **User Creation**:
   - Creates a new user with a validated username (lowercase, starts with letter).
   - Sets a secure password (interactive or via `CI_PASSWORD` environment variable).
   - Assigns `zsh` (if installed) or `ash` as the shell.
   - Adds user to `wheel` and `docker` groups.

2. **Passwordless Doas**:
   - Configures `permit nopass :wheel` in `/etc/doas.d/wheel.conf` for CI/CD automation.
   - Sets strict permissions (`600`) on `doas` configuration.

3. **SSH Setup**:
   - Copies root’s `authorized_keys` or uses `CI_SSH_KEY` for SSH access.
   - Sets strict permissions (`700` for `.ssh`, `600` for `authorized_keys`).

4. **SSH Hardening**:
   - Disables password authentication, root login, and PAM.
   - Limits SSH to the new user (`AllowUsers`).
   - Sets `MaxAuthTries` to 3 to deter brute-force attacks.

5. **Fail2ban**:
   - Installs and configures `fail2ban` to ban IPs after 3 failed SSH attempts (1-hour ban).

6. **System Security**:
   - Sets `umask 027` in `/etc/profile` for stricter file permissions.
   - Applies sysctl settings to prevent IP spoofing, disable IP forwarding, and enable SYN cookies.
   - Persists sysctl configurations in `/etc/sysctl.conf`.

7. **Zsh Configuration**:
   - Creates a minimal `.zshrc` with history deduplication and no terminal bell.
   - Sets secure permissions (`600`).

8. **CI/CD Support**:
   - Accepts `CI_PASSWORD` and `CI_SSH_KEY` for non-interactive execution.
   - Ensures passwordless `doas` for pipeline automation.

## Why It Does This
- **Security**: Root login and password-based SSH are common attack vectors. Disabling them reduces risk.
- **Privacy**: Strict file permissions and history deduplication protect user data.
- **Automation**: Passwordless `doas` and environment variable support streamline CI/CD workflows.
- **Resilience**: Fail2ban and network protections mitigate brute-force and spoofing attacks.
- **Consistency**: Automated setup ensures uniform server configurations across deployments.

## Usage
```bash
chmod +x initial-setup.sh
./initial-setup.sh
```
- Interactive: Prompts for username and password.
- CI/CD: Set `CI_PASSWORD` and `CI_SSH_KEY` environment variables for non-interactive runs.

## Prerequisites
- Alpine Linux 3.17 or later.
- Root access.
- Internet access for package installation.

## Security Considerations
- **Passwordless Doas**: Convenient for CI/CD but risky if the user account is compromised. Consider limiting commands in `doas.conf`.
- **SSH Keys**: Copying root’s keys is convenient but less secure than generating unique keys.
- **Fail2ban**: Adjust `bantime` or `maxretry` based on your threat model.

## Future Improvements
- Add `ufw` or `iptables` to restrict inbound traffic.
- Generate unique SSH keys for the user.
- Enable `auditd` or similar for system change tracking.
- Validate `docker` group existence before assignment.