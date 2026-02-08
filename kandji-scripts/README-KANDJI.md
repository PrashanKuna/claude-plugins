# Kandji Deployment Guide

## Overview

Two scripts that deploy the Google Workspace MCP plugin to your team's Claude Code installations via Kandji. After deployment, the only thing each user does is **sign in with Google** when prompted.

## Before You Deploy

1. **Make the marketplace repo public:**
   ```
   gh repo edit PrashanKuna/claude-plugins --visibility public
   ```
   (Or do it in GitHub Settings > General > Danger Zone > Change visibility)

2. **Edit `01-setup-google-oauth-env.sh`** and replace the two placeholder values with your actual Google OAuth credentials.

## Deployment Order

### Script 1: `01-setup-google-oauth-env.sh`
**What it does:** Adds `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET` to the user's `~/.zshrc`.

**Kandji settings:**
- Library Item: Custom Script
- Execution: Run once per device
- Run as: Current User (or root — script handles user detection)

### Script 2: `02-install-claude-plugin.sh`
**What it does:** Adds the ada-tools marketplace and installs the Google Workspace MCP plugin in Claude Code.

**Kandji settings:**
- Library Item: Custom Script
- Execution: Run once per device
- Run as: Current User (or root — script handles user detection)
- **Deploy after** Script 1

## What Happens on the User's Machine

1. Scripts run silently in the background
2. Next time the user opens Claude Code, the Google Workspace tools are available
3. First time they use a Google tool, a browser window opens to sign in with Google
4. After sign-in, everything works — no further setup needed

## Troubleshooting

**"Claude Code CLI not found"**
- Claude Code may not be installed yet on that machine
- The script exits gracefully — user can install manually later

**User needs to install manually:**
```
/plugin marketplace add PrashanKuna/claude-plugins
/plugin install google-workspace-mcp@ada-tools
```

**Env vars not taking effect:**
- User needs to restart their terminal or run `source ~/.zshrc`
- Restarting Claude Code picks up the new env vars
