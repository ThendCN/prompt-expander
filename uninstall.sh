#!/bin/bash
# Prompt Expander - Uninstaller
# Usage: curl -fsSL https://raw.githubusercontent.com/ThendCN/prompt-expander/main/uninstall.sh | bash

set -e

CLAUDE_DIR="$HOME/.claude"

echo "🗑️  Uninstalling Prompt Expander..."

# Remove files
rm -rf "$CLAUDE_DIR/skills/prompt-expander"
rm -f "$CLAUDE_DIR/hooks/expand-prompt.sh"
rm -f "$CLAUDE_DIR/commands/expand.md"

# Remove hooks from settings.json
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [[ -f "$SETTINGS_FILE" ]] && command -v jq &> /dev/null; then
    if jq -e '.hooks.UserPromptSubmit' "$SETTINGS_FILE" > /dev/null 2>&1; then
        jq 'del(.hooks)' "$SETTINGS_FILE" > tmp.json && mv tmp.json "$SETTINGS_FILE"
        echo "✅ Removed hooks from settings.json"
    fi
fi

echo ""
echo "✅ Uninstall complete!"
echo "⚠️  Restart Claude Code to apply changes"
