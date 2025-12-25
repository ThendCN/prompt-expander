#!/bin/bash
# Prompt Expander - One-click installer for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/ThendCN/prompt-expander/main/install.sh | bash

set -e

REPO_URL="https://raw.githubusercontent.com/ThendCN/prompt-expander/main"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 Installing Prompt Expander for Claude Code..."

# Create directories
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/skills/prompt-expander/data"
mkdir -p "$CLAUDE_DIR/skills/prompt-expander/scripts"

# Download files
echo "📥 Downloading files..."
curl -fsSL "$REPO_URL/expand.md" -o "$CLAUDE_DIR/commands/expand.md"
curl -fsSL "$REPO_URL/expand-prompt.sh" -o "$CLAUDE_DIR/hooks/expand-prompt.sh"
curl -fsSL "$REPO_URL/SKILL.md" -o "$CLAUDE_DIR/skills/prompt-expander/SKILL.md"
curl -fsSL "$REPO_URL/scripts/copy-to-clipboard.sh" -o "$CLAUDE_DIR/skills/prompt-expander/scripts/copy-to-clipboard.sh"
curl -fsSL "$REPO_URL/scripts/record-feedback.sh" -o "$CLAUDE_DIR/skills/prompt-expander/scripts/record-feedback.sh"

# Initialize data files
echo '{"history": []}' > "$CLAUDE_DIR/skills/prompt-expander/data/feedback.json"
echo '{"verbosity": "standard", "preferences": {}}' > "$CLAUDE_DIR/skills/prompt-expander/data/profile.json"
echo '{"intent": "", "setAt": ""}' > "$CLAUDE_DIR/skills/prompt-expander/data/intent.json"

# Set permissions
chmod +x "$CLAUDE_DIR/hooks/expand-prompt.sh"
chmod +x "$CLAUDE_DIR/skills/prompt-expander/scripts/"*.sh

# Update settings.json
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [[ -f "$SETTINGS_FILE" ]]; then
    # Check if hooks already configured
    if grep -q "UserPromptSubmit" "$SETTINGS_FILE"; then
        echo "⚠️  Hooks already configured in settings.json, skipping..."
    else
        # Add hooks to existing settings
        if command -v jq &> /dev/null; then
            jq '.hooks = {"UserPromptSubmit": [{"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/hooks/expand-prompt.sh"}]}]}' "$SETTINGS_FILE" > tmp.json && mv tmp.json "$SETTINGS_FILE"
            echo "✅ Updated settings.json with hooks"
        else
            echo "⚠️  jq not found. Please manually add hooks to settings.json"
            echo "   See README for manual configuration"
        fi
    fi
else
    # Create new settings.json
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/expand-prompt.sh"
          }
        ]
      }
    ]
  }
}
EOF
    echo "✅ Created settings.json"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Usage:"
echo "  * your instruction     - Smart expand"
echo "  ** your instruction    - Expand and execute"
echo "  *goal: your goal       - Set session intent"
echo ""
echo "⚠️  Restart Claude Code to apply changes"
