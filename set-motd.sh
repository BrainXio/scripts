#!/bin/sh
# -----------------------------------------------------------------------------
# set-motd.sh — Set a unified MOTD with host info and configurable tags.
# Works on most Linux distros (Alpine, Ubuntu, Debian, CentOS, etc.).
# -----------------------------------------------------------------------------

set -eu

# Persistent tags file
TAGS_FILE="/etc/motd-tags"
[ ! -f "$TAGS_FILE" ] && touch "$TAGS_FILE" && chmod 644 "$TAGS_FILE"

# MOTD file
MOTD_FILE="/etc/motd"

# Usage info
usage() {
    echo "Usage: $0 [--add tag] [--remove tag] [--list-tags]"
    echo "  --add tag      Add a tag to the MOTD"
    echo "  --remove tag   Remove a tag from the MOTD"
    echo "  --list-tags    List current tags"
    echo "  (no args)      Update MOTD with host info and tags"
    exit 1
}

# Parse arguments
ACTION=""
TAG=""
while [ $# -gt 0 ]; do
    case "$1" in
        --add) ACTION="add"; TAG="$2"; shift 2 ;;
        --remove) ACTION="remove"; TAG="$2"; shift 2 ;;
        --list-tags) ACTION="list"; shift ;;
        *) usage ;;
    esac
done

# Validate tag format (alphanumeric, hyphens, underscores)
validate_tag() {
    echo "$1" | grep -qE '^[a-zA-Z0-9_-]+$' || { echo "⚠️ Invalid tag: use alphanumeric, hyphens, underscores"; exit 1; }
}

# Add tag
add_tag() {
    validate_tag "$1"
    if grep -Fx "$1" "$TAGS_FILE" >/dev/null; then
        echo "⚠️ Tag '$1' already exists."
        return
    fi
    echo "$1" >> "$TAGS_FILE"
    echo "✅ Tag '$1' added."
}

# Remove tag
remove_tag() {
    validate_tag "$1"
    if ! grep -Fx "$1" "$TAGS_FILE" >/dev/null; then
        echo "⚠️ Tag '$1' not found."
        return
    fi
    sed -i "/^$1$/d" "$TAGS_FILE"
    echo "✅ Tag '$1' removed."
}

# List tags
list_tags() {
    echo "Current tags:"
    [ -s "$TAGS_FILE" ] && cat "$TAGS_FILE" || echo "(none)"
}

# Generate MOTD
generate_motd() {
    # Gather host info
    HOSTNAME=$(hostname)
    
    # Get OS info
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="${PRETTY_NAME:-Unknown Linux}"
    else
        OS=$(uname -s -r)
    fi
    
    # Get IP address (try ip, then ifconfig, then fallback)
    IP=""
    if command -v ip >/dev/null 2>&1; then
        IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 | head -1)
    elif command -v ifconfig >/dev/null 2>&1; then
        IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
    fi
    [ -z "$IP" ] && IP="Unknown"

    # Get uptime
    UPTIME=$(uptime | sed 's/.*up \([^,]*\),.*/\1/' || echo "Unknown")

    # Get tags
    TAGS=$( [ -s "$TAGS_FILE" ] && cat "$TAGS_FILE" | tr '\n' ',' | sed 's/,$//' || echo "none")

    # Write MOTD
    cat > "$MOTD_FILE" <<EOF
Welcome to $HOSTNAME

System Information:
-------------------
OS: $OS
IP Address: $IP
Uptime: $UPTIME
Tags: $TAGS

Login time: $(date)
-------------------
EOF
    chmod 644 "$MOTD_FILE"
    echo "✅ MOTD updated."
}

# Execute action
case "$ACTION" in
    add) add_tag "$TAG"; generate_motd ;;
    remove) remove_tag "$TAG"; generate_motd ;;
    list) list_tags ;;
    *) generate_motd ;;
esac