#!/bin/bash
###############################################################################
# Google Workspace MCP — Claude Code Plugin Install
# Deploy via Kandji as a Custom Script (run once per user)
#
# What this does:
#   1. Adds the ada-tools plugin marketplace to Claude Code
#   2. Installs the google-workspace-mcp plugin
#
# Prerequisites:
#   - Claude Code CLI must be installed (brew install claude-code or npm)
#   - The marketplace repo must be public (or user has GitHub access)
#   - Run AFTER 01-setup-google-oauth-env.sh
###############################################################################

# Detect the current user
CURRENT_USER=$(stat -f "%Su" /dev/console 2>/dev/null || echo "$USER")
USER_HOME=$(eval echo "~$CURRENT_USER")

# Find the claude binary (could be in various locations)
CLAUDE_BIN=""
for path in \
    "/usr/local/bin/claude" \
    "$USER_HOME/.npm-global/bin/claude" \
    "$USER_HOME/.local/bin/claude" \
    "/opt/homebrew/bin/claude"; do
    if [ -x "$path" ]; then
        CLAUDE_BIN="$path"
        break
    fi
done

# Also check if it's on the user's PATH
if [ -z "$CLAUDE_BIN" ]; then
    CLAUDE_BIN=$(sudo -u "$CURRENT_USER" bash -lc "which claude" 2>/dev/null)
fi

if [ -z "$CLAUDE_BIN" ]; then
    echo "Claude Code CLI not found — skipping plugin install."
    echo "The user can install manually later with:"
    echo "  /plugin marketplace add PrashanKuna/claude-plugins"
    echo "  /plugin install google-workspace-mcp@ada-tools"
    exit 0
fi

echo "Found Claude Code at: $CLAUDE_BIN"

# --- Install uv (required to run the Google Workspace MCP server) ---
if ! command -v /opt/homebrew/bin/uv &> /dev/null && ! command -v /usr/local/bin/uv &> /dev/null; then
    echo "Installing uv via Homebrew..."
    sudo -u "$CURRENT_USER" bash -lc "brew install uv 2>&1"
else
    echo "uv already installed"
fi

# Run as the actual user (not root)
sudo -u "$CURRENT_USER" bash -lc "
    '$CLAUDE_BIN' plugin marketplace add PrashanKuna/claude-plugins 2>&1
    '$CLAUDE_BIN' plugin install google-workspace-mcp@ada-tools 2>&1
"

if [ $? -eq 0 ]; then
    echo "Google Workspace MCP plugin installed for user $CURRENT_USER"
else
    echo "Plugin install encountered an issue. User can install manually with:"
    echo "  /plugin marketplace add PrashanKuna/claude-plugins"
    echo "  /plugin install google-workspace-mcp@ada-tools"
fi

exit 0
