#!/usr/bin/env bash
set -euo pipefail

BIN_TARGET="/usr/local/bin/avabatt"
SYSTEMD_TARGET="/etc/systemd/system/avabatt.service"

echo "============================================================"
echo "                   avabatt Installer                        "
echo "============================================================"

SCRIPT_DIR=""
if [ -f "./avabatt" ]; then
    SCRIPT_DIR="$(pwd)"
elif [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    if [ -f "$DIR/avabatt" ]; then
        SCRIPT_DIR="$DIR"
    fi
fi

if [ -n "$SCRIPT_DIR" ]; then
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$SCRIPT_DIR/avabatt" "$BIN_TARGET"
    sudo chmod +x "$BIN_TARGET"
    echo "✓ avabatt linked to $BIN_TARGET"

    if [ -f "$SCRIPT_DIR/avabatt.service" ]; then
        sudo cp "$SCRIPT_DIR/avabatt.service" "$SYSTEMD_TARGET"
        sudo systemctl daemon-reload
        sudo systemctl enable avabatt.service 2>/dev/null || true
        echo "✓ avabatt.service installed and enabled for boot/resume persistence"
    fi
else
    TMP_DIR=$(mktemp -d /tmp/avabatt-install.XXXXXX)
    trap 'rm -rf "$TMP_DIR"' EXIT

    git clone --depth 1 https://github.com/telosdevgroup/avabatt.git "$TMP_DIR/avabatt"
    sudo mkdir -p /usr/local/bin
    sudo cp "$TMP_DIR/avabatt/avabatt" "$BIN_TARGET"
    sudo chmod +x "$BIN_TARGET"
    echo "✓ avabatt installed to $BIN_TARGET"

    if [ -f "$TMP_DIR/avabatt/avabatt.service" ]; then
        sudo cp "$TMP_DIR/avabatt/avabatt.service" "$SYSTEMD_TARGET"
        sudo systemctl daemon-reload
        sudo systemctl enable avabatt.service 2>/dev/null || true
        echo "✓ avabatt.service installed and enabled for boot/resume persistence"
    fi
fi

echo ""
echo "Installation complete! Run 'avabatt status' to verify."
