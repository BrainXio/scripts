#!/bin/sh
# -----------------------------------------------------------------------------
# set-ssh-banner.sh — Set a pre-login SSH banner with host info and optional tags.
# Designed for Alpine Linux (3.17+).
# -----------------------------------------------------------------------------

set -eu

# Files
BANNER_FILE="/etc/ssh/banner"
SSHCFG="/etc/ssh/sshd_config"
TAGS_FILE="/etc/motd-tags"

# Default banner message
DEFAULT_MESSAGE="Authorized users only. All activity is logged."

# Usage info
usage() {
    echo "Usage: $0 [--message 'custom message'] [--include-tags] [--disable]"
    echo "  --message 'text'  Set custom banner message"
    echo "  --include-tags    Include tags from $TAGS_FILE"
    echo "  --disable         Disable banner and remove $BANNER_FILE"
    exit 1
}

# Parse arguments
MESSAGE="$DEFAULT_MESSAGE"
INCLUDE_TAGS="false"
ACTION="enable"
while [ $# -gt 0 ]; do
    case "$1" in
        --message) MESSAGE="$2"; shift 2 ;;
        --include-tags) INCLUDE_TAGS="true"; shift ;;
        --disable) ACTION="disable"; shift ;;
        *) usage ;;
    esac
done

# Update sshd_config
patch_line() {
    key=$1 value=$2
    grep -qiE "^\s*#?\s*${key}\s+" "$SSHCFG" && \
        sed -Ei "s|^\s*#?\s*${key}\s+.*|${key} ${value}|I" "$SSHCFG" || \
        echo "${key} ${value}" >> "$SSHCFG"
}

# Generate banner
generate_banner() {
    # Gather host info
    HOSTNAME=$(hostname)
    TAGS=""
    if [ "$INCLUDE_TAGS" = "true" ] && [ -s "$TAGS_FILE" ]; then
        TAGS=$(cat "$TAGS_FILE" | tr '\n' ',' | sed 's/,$//')
    fi

    # Write banner
    echo "Welcome to $HOSTNAME" > "$BANNER_FILE"
    [ -n "$TAGS" ] && echo "Tags: $TAGS" >> "$BANNER_FILE"
    echo "$MESSAGE" >> "$BANNER_FILE"
    chmod 644 "$BANNER_FILE"
}

# Main logic
if [ "$ACTION" = "disable" ]; then
    # Disable banner
    patch_line "Banner" "none"
    [ -f "$BANNER_FILE" ] && rm "$BANNER_FILE"
    echo "✅ SSH banner disabled."
else
    # Enable banner
    generate_banner
    patch_line "Banner" "$BANNER_FILE"
    echo "✅ SSH banner set."
fi

# Validate and reload SSH
sshd -t && rc-service sshd restart