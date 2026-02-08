#!/bin/bash
###############################################################################
# Google Workspace MCP — OAuth Environment Variables
# Deploy via Kandji as a Custom Script (run once per user)
#
# What this does:
#   Adds the shared Google OAuth credentials to the user's shell profile
#   so Claude Code can connect to Google Workspace APIs.
#
# BEFORE DEPLOYING: Replace the placeholder values below with your actual
# Google OAuth Client ID and Client Secret from Google Cloud Console.
###############################################################################

# ============================================================================
# REPLACE THESE WITH YOUR ACTUAL CREDENTIALS
# ============================================================================
GOOGLE_CLIENT_ID="PASTE_YOUR_CLIENT_ID_HERE.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="PASTE_YOUR_CLIENT_SECRET_HERE"
# ============================================================================

# Detect the current user (Kandji runs as root, so we need the logged-in user)
CURRENT_USER=$(stat -f "%Su" /dev/console 2>/dev/null || echo "$USER")
USER_HOME=$(eval echo "~$CURRENT_USER")

# Determine shell profile file
if [ -f "$USER_HOME/.zshrc" ]; then
    PROFILE="$USER_HOME/.zshrc"
elif [ -f "$USER_HOME/.bashrc" ]; then
    PROFILE="$USER_HOME/.bashrc"
else
    PROFILE="$USER_HOME/.zshrc"
    touch "$PROFILE"
    chown "$CURRENT_USER" "$PROFILE"
fi

# Remove any existing Google OAuth vars (so we always apply the latest values)
sed -i '' '/GOOGLE_OAUTH_CLIENT_ID/d' "$PROFILE"
sed -i '' '/GOOGLE_OAUTH_CLIENT_SECRET/d' "$PROFILE"
sed -i '' '/Google Workspace MCP.*OAuth/d' "$PROFILE"

# Append credentials
cat >> "$PROFILE" << EOF

# Google Workspace MCP — OAuth credentials (deployed by IT)
export GOOGLE_OAUTH_CLIENT_ID="$GOOGLE_CLIENT_ID"
export GOOGLE_OAUTH_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET"
EOF

# Fix ownership (since Kandji may run as root)
chown "$CURRENT_USER" "$PROFILE"

echo "Google OAuth env vars added to $PROFILE for user $CURRENT_USER"
exit 0
