#!/bin/bash
###############################################################################
# Google Workspace MCP — OAuth Environment Variables
# Deploy via Kandji as a Custom Script
#
# BEFORE DEPLOYING: Replace the placeholder values on lines 14-15 with your
# actual Google OAuth Client ID and Client Secret from Google Cloud Console.
###############################################################################

# ============================================================================
# REPLACE THESE WITH YOUR ACTUAL CREDENTIALS
# ============================================================================
GOOGLE_CLIENT_ID="PASTE_YOUR_CLIENT_ID_HERE.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="PASTE_YOUR_CLIENT_SECRET_HERE"
# ============================================================================

LOG_PREFIX="[GoogleMCP]"

# --- Detect the logged-in user ---
# Try multiple methods since Kandji runs as root
CURRENT_USER=""

# Method 1: Console user
CURRENT_USER=$(stat -f "%Su" /dev/console 2>/dev/null)

# Method 2: scutil (more reliable on newer macOS)
if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" = "root" ]; then
    CURRENT_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }' 2>/dev/null)
fi

# Method 3: Last logged-in user
if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" = "root" ] || [ "$CURRENT_USER" = "loginwindow" ]; then
    CURRENT_USER=$(last -1 -t ttys000 2>/dev/null | head -1 | awk '{print $1}')
fi

# Bail if we still can't find a real user
if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" = "root" ] || [ "$CURRENT_USER" = "loginwindow" ]; then
    echo "$LOG_PREFIX ERROR: Could not detect logged-in user. Exiting."
    exit 1
fi

USER_HOME=$(dscl . -read /Users/"$CURRENT_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')
if [ -z "$USER_HOME" ]; then
    USER_HOME="/Users/$CURRENT_USER"
fi

echo "$LOG_PREFIX Detected user: $CURRENT_USER"
echo "$LOG_PREFIX Home directory: $USER_HOME"

# --- Use .zshenv (loaded by ALL shell types, including non-interactive) ---
# .zshrc only loads for interactive shells, which Claude Code may not use.
# .zshenv is always loaded, so env vars are available everywhere.
PROFILE="$USER_HOME/.zshenv"
if [ ! -f "$PROFILE" ]; then
    touch "$PROFILE"
    chown "$CURRENT_USER" "$PROFILE"
fi

echo "$LOG_PREFIX Using profile: $PROFILE"

# --- Remove any existing Google OAuth vars from .zshenv AND .zshrc ---
sed -i '' '/GOOGLE_OAUTH_CLIENT_ID/d' "$PROFILE"
sed -i '' '/GOOGLE_OAUTH_CLIENT_SECRET/d' "$PROFILE"
sed -i '' '/Google Workspace MCP.*OAuth/d' "$PROFILE"

# Also clean up .zshrc if it has old values from a previous deployment
ZSHRC="$USER_HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    sed -i '' '/GOOGLE_OAUTH_CLIENT_ID/d' "$ZSHRC"
    sed -i '' '/GOOGLE_OAUTH_CLIENT_SECRET/d' "$ZSHRC"
    sed -i '' '/Google Workspace MCP.*OAuth/d' "$ZSHRC"
fi

# --- Write the credentials ---
cat >> "$PROFILE" << EOF

# Google Workspace MCP — OAuth credentials (deployed by IT)
export GOOGLE_OAUTH_CLIENT_ID="$GOOGLE_CLIENT_ID"
export GOOGLE_OAUTH_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET"
EOF

# --- Fix ownership ---
chown "$CURRENT_USER" "$PROFILE"

# --- Verify it worked ---
if grep -q "$GOOGLE_CLIENT_ID" "$PROFILE" 2>/dev/null; then
    echo "$LOG_PREFIX SUCCESS: OAuth env vars written to $PROFILE"
else
    echo "$LOG_PREFIX ERROR: Failed to write env vars to $PROFILE"
    exit 1
fi

exit 0
