#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="com.modernclock.plasma6"

if kpackagetool6 --type Plasma/Applet --show "$PLUGIN_ID" >/dev/null 2>&1; then
    echo "Upgrading existing $PLUGIN_ID..."
    kpackagetool6 --type Plasma/Applet --upgrade "$SCRIPT_DIR"
else
    echo "Installing $PLUGIN_ID..."
    kpackagetool6 --type Plasma/Applet --install "$SCRIPT_DIR"
fi

echo ""
echo "Done! You can now add 'Đồng Hồ & Lịch Hiện Đại' (Modern Clock & Calendar) to your panel or desktop."
echo "To preview immediately in a standalone window, run:"
echo "  plasmawindowed $PLUGIN_ID"
