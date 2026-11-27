#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="com.modernclock.plasma6"

RESTART_PLASMA=true
OPEN_PREVIEW=false

for arg in "$@"; do
    case "$arg" in
        --no-restart)
            RESTART_PLASMA=false
            ;;
        --preview)
            OPEN_PREVIEW=true
            RESTART_PLASMA=false
            ;;
        -h|--help)
            echo "Usage: ./update.sh [--no-restart | --preview]"
            echo "  (default)     Upgrade widget and restart Plasma shell to apply changes"
            echo "  --no-restart  Only upgrade widget package without restarting Plasma"
            echo "  --preview     Upgrade widget and launch standalone preview (plasmawindowed)"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

if kpackagetool6 --type Plasma/Applet --show "$PLUGIN_ID" >/dev/null 2>&1; then
    echo "Upgrading $PLUGIN_ID..."
    kpackagetool6 --type Plasma/Applet --upgrade "$SCRIPT_DIR"
else
    echo "Installing $PLUGIN_ID..."
    kpackagetool6 --type Plasma/Applet --install "$SCRIPT_DIR"
fi

if [ "$OPEN_PREVIEW" = true ]; then
    echo "Launching preview window..."
    exec plasmawindowed "$PLUGIN_ID"
fi

if [ "$RESTART_PLASMA" = true ]; then
    echo "Reloading Plasma shell..."
    if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet plasma-plasmashell.service; then
        systemctl --user restart plasma-plasmashell.service
    elif command -v plasmashell >/dev/null 2>&1; then
        nohup plasmashell --replace >/dev/null 2>&1 &
        disown || true
    fi
    echo "Updated and reloaded successfully!"
else
    echo "Updated successfully (Plasma shell not restarted)."
fi
