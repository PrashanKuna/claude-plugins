# Google Workspace MCP — Team Deployment Guide

## What This Is

A Claude Code plugin marketplace that gives your team access to Google Workspace tools (Gmail, Calendar, Drive, Docs, Sheets, etc.) directly from Claude Code.

## For Admins: Publishing the Marketplace

### 1. Push this repo to GitHub

```bash
cd claude-plugins
git init
git add .
git commit -m "Initial marketplace with Google Workspace MCP plugin"
git remote add origin https://github.com/PrashanKuna/claude-plugins.git
git push -u origin main
```

### 2. Share a Google OAuth app with your team

Create **one** OAuth 2.0 Client ID in Google Cloud Console for the whole team:

1. Go to [Google Cloud Console](https://console.cloud.google.com/) > APIs & Services > Credentials
2. Create an OAuth 2.0 Client ID (type: **Desktop application**)
3. Enable the APIs your team needs (Gmail, Calendar, Drive, Docs, Sheets)
4. Share the `Client ID` and `Client Secret` with your team (e.g., via a secure internal doc)

### 3. Auto-enable for team repos

Copy the contents of `team-settings.json` into `.claude/settings.json` in any shared repo:

```json
{
  "extraKnownMarketplaces": {
    "ada-tools": {
      "source": {
        "source": "github",
        "repo": "PrashanKuna/claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "google-workspace-mcp@ada-tools": true
  }
}
```

Team members who trust the repo will be prompted to install automatically.

---

## For Team Members: One-Time Setup

### Step 1: Install the marketplace

In Claude Code, run:

```
/plugin marketplace add PrashanKuna/claude-plugins
```

### Step 2: Install the plugin

```
/plugin install google-workspace-mcp@ada-tools
```

### Step 3: Set your environment variables

Add these to your shell profile (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
export GOOGLE_OAUTH_CLIENT_ID="<client-id-from-your-admin>"
export GOOGLE_OAUTH_CLIENT_SECRET="<client-secret-from-your-admin>"
```

Then restart your terminal or run `source ~/.zshrc`.

### Step 4: Authenticate with Google

The first time you use a Google tool in Claude Code, you'll be prompted to authenticate via your browser. This is a one-time step per user.

---

## Available Tool Tiers

The plugin is configured with the `core` tier by default. To change it, edit `plugins/google-workspace-mcp/.claude-plugin/plugin.json` and update the args:

| Tier | What's included |
|------|----------------|
| `core` | Essential read/write for Gmail, Calendar, Drive, Docs, Sheets |
| `extended` | Core + advanced features (permissions, export, copy) |
| `complete` | All tools including comments, batch ops, Apps Script |

---

## Directory Structure

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace definition
├── plugins/
│   └── google-workspace-mcp/
│       └── .claude-plugin/
│           └── plugin.json       # Plugin manifest + MCP server config
├── team-settings.json            # Copy into .claude/settings.json in your repos
├── .env.example                  # Environment variable reference
└── SETUP.md                      # This file
```

## Updating

To update the plugin version, edit the version in both:
- `plugins/google-workspace-mcp/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`

Then push to GitHub. Team members can update with:

```
/plugin marketplace update
/plugin update google-workspace-mcp@ada-tools
```
