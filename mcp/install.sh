#!/bin/bash
# Install DonkeyUI MCP into the current repo.
# Usage: Run from any repo root:
#   bash /Users/franciscosainzwilliams/Documents/GitHub/DonkeyUI/mcp/install.sh
#
# Or with the alias:
#   donkeyui-mcp

DONKEYUI_MCP="/Users/franciscosainzwilliams/Documents/GitHub/DonkeyUI/mcp"
TARGET=".mcp.json"

# If .mcp.json already exists, merge the donkeyui server into it
if [ -f "$TARGET" ]; then
    # Check if donkeyui is already configured
    if grep -q "donkeyui" "$TARGET" 2>/dev/null; then
        echo "DonkeyUI MCP already configured in $TARGET"
        exit 0
    fi

    # Merge: add donkeyui to existing mcpServers
    node -e "
        const fs = require('fs');
        const config = JSON.parse(fs.readFileSync('$TARGET', 'utf-8'));
        config.mcpServers = config.mcpServers || {};
        config.mcpServers.donkeyui = {
            command: 'node',
            args: ['$DONKEYUI_MCP/server.mjs']
        };
        fs.writeFileSync('$TARGET', JSON.stringify(config, null, 2) + '\n');
    "
    echo "Added DonkeyUI MCP to existing $TARGET"
else
    # Create new .mcp.json
    cat > "$TARGET" << EOF
{
  "mcpServers": {
    "donkeyui": {
      "command": "node",
      "args": ["$DONKEYUI_MCP/server.mjs"]
    }
  }
}
EOF
    echo "Created $TARGET with DonkeyUI MCP"
fi

echo "Restart Claude Code to pick up the new MCP server."
