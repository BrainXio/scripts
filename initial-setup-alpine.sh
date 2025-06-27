#!/bin/sh
# -----------------------------------------------------------------------------
# initial-setup.sh — Create non-root admin user, harden SSH, and optimize for CI/CD.
# Designed for Alpine Linux (3.17+).
# -----------------------------------------------------------------------------

set -eu

# Install zsh, doas, and fail2ban
apk update && apk add --no-cache zsh shadow doas fail2ban openssh

ZSH_BIN=$(command -v zsh || true)
[ -n "$ZSH_BIN" ] && ! grep -Fx "$ZSH_BIN" /etc/shells >/dev/null && echo "$ZSH_BIN" >> /etc/shells

# Get valid username
while true; do
    printf "Enter username (lowercase, start with letter): "
    read username
    echo "$username" | grep -qE '^[a-z][-a-z0-9_]*$' && break
    echo "⚠️ Invalid username."
done

# Get and confirm password (optional for CI/CD)
if [ -z "${CI_PASSWORD:-}" ]; then
    while true; do
        printf "Enter password: "
        stty -echo; read password1; stty echo; echo
        printf "Confirm password: "
        stty -echo; read password2; stty echo; echo
        [ "$password1" = "$password2" ] && [ -n "$password1" ] && break
        echo "⚠️ Passwords do not match."
    done
else
    password1="$CI_PASSWORD"
fi

# Check if user exists
id "$username" >/dev/null 2>&1 && { echo "❌ User $username exists."; exit 1; }

# Create user with passwordless doas
default_shell=${ZSH_BIN:-/bin/ash}
adduser -h /home/"$username" -s "$default_shell" -G wheel,docker -D "$username"
echo "${username}:${password1}" | chpasswd

# Configure passwordless doas
echo "permit nopass :wheel" > /etc/doas.d/wheel.conf
chmod 600 /etc/doas.d/wheel.conf

# Set up SSH for user
mkdir -p -m 700 /home/"$username"/.ssh
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/"$username"/.ssh/
    chmod 600 /home/"$username"/.ssh/authorized_keys
    chown -R "$username":"$username" /home/"$username"/.ssh
elif [ -n "${CI_SSH_KEY:-}" ]; then
    echo "$CI_SSH_KEY" > /home/"$username"/.ssh/authorized_keys
    chmod 600 /home/"$username"/.ssh/authorized_keys
    chown -R "$username":"$username" /home/"$username"/.ssh
fi

# Configure zsh with secure defaults
if [ -x "$ZSH_BIN" ]; then
    cat > /home/"$username"/.zshrc <<'EOF'
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt inc_append_history share_history hist_ignore_all_dups
unsetopt beep
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '
EOF
    chmod 600 /home/"$username"/.zshrc
    chown "$username":"$username" /home/"$username"/.zshrc
fi

# Create .config directory
mkdir -p -m 700 /home/"$username"/.config
chown -R "$username":"$username" /home/"$username"/.config

# Harden SSH
SSHCFG='/etc/ssh/sshd_config'
cp "$SSHCFG" "${SSHCFG}.bak"

patch_line() {
    key=$1 value=$2
    grep -qiE "^\s*#?\s*${key}\s+" "$SSHCFG" && \
        sed -Ei "s|^\s*#?\s*${key}\s+.*|${key} ${value}|I" "$SSHCFG" || \
        echo "${key} ${value}" >> "$SSHCFG"
}

patch_line "PasswordAuthentication" "no"
patch_line "PermitRootLogin" "no"
patch_line "UsePAM" "no"
patch_line "MaxAuthTries" "3"
patch_line "AllowUsers" "$username"

# Configure fail2ban for SSH
cat > /etc/fail2ban/jail.local <<'EOF'
[sshd]
enabled = true
port = ssh
maxretry = 3
bantime = 3600
findtime = 600
EOF
rc-service fail2ban restart

# Secure system settings
echo "umask 027" >> /etc/profile
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv4.tcp_syncookies=1
echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward=0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf

# Validate and reload SSH
sshd -t && rc-service sshd restart

echo "✅ User $username created, SSH hardened, system secured."