#!/bin/bash
# Install DonkeyUI MCP for Claude Code and/or Codex.
#
# Usage:
#   bash /path/to/DonkeyUI/mcp/install.sh          # installs for both
#   bash /path/to/DonkeyUI/mcp/install.sh claude    # Claude Code only
#   bash /path/to/DonkeyUI/mcp/install.sh codex     # Codex only

set -e

DONKEYUI_MCP="$(cd "$(dirname "$0")" && pwd)"
SERVER="$DONKEYUI_MCP/server.mjs"
TARGET="${1:-both}"

# ── Claude Code (global) ──

install_claude() {
    local SETTINGS="$HOME/.claude/settings.local.json"
    mkdir -p "$(dirname "$SETTINGS")"

    if [ -f "$SETTINGS" ] && grep -q "donkeyui" "$SETTINGS" 2>/dev/null; then
        echo "[Claude] Already configured in $SETTINGS"
        return
    fi

    if [ -f "$SETTINGS" ] && [ -s "$SETTINGS" ]; then
        node -e "
            const fs = require('fs');
            const config = JSON.parse(fs.readFileSync('$SETTINGS', 'utf-8'));
            config.mcpServers = config.mcpServers || {};
            config.mcpServers.donkeyui = { command: 'node', args: ['$SERVER'] };
            fs.writeFileSync('$SETTINGS', JSON.stringify(config, null, 2) + '\n');
        "
    else
        cat > "$SETTINGS" << EOF
{
  "mcpServers": {
    "donkeyui": {
      "command": "node",
      "args": ["$SERVER"]
    }
  }
}
EOF
    fi
    echo "[Claude] Installed globally → $SETTINGS"
}

# ── Codex ──

install_codex() {
    local CONFIG="$HOME/.codex/config.toml"

    if [ ! -f "$CONFIG" ]; then
        echo "[Codex] No config.toml found at $CONFIG — skipping"
        return
    fi

    if grep -q "donkeyui" "$CONFIG" 2>/dev/null; then
        echo "[Codex] Already configured in $CONFIG"
        return
    fi

    # Append MCP server config
    cat >> "$CONFIG" << EOF

[mcp_servers.donkeyui]
command = "node"
args = ["$SERVER"]
EOF
    echo "[Codex] Installed → $CONFIG"
}

# ── Run ──

case "$TARGET" in
    claude) install_claude ;;
    codex)  install_codex ;;
    both|"")
        install_claude
        install_codex
        ;;
    *)
        echo "Usage: install.sh [claude|codex|both]"
        exit 1
        ;;
esac

echo ""
echo "Restart your AI tool to pick up the DonkeyUI MCP server."
echo "Tools available: search_components, get_component, list_categories, list_components, get_theme_setup, get_usage_example"
