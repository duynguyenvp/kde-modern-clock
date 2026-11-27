#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ID="com.modernclock.plasma6"

echo "Removing $PLUGIN_ID..."
kpackagetool6 --type Plasma/Applet --remove "$PLUGIN_ID"
echo "Done!"
