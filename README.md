# Prompt Expander for Claude Code

Turn short instructions into detailed, actionable prompts with AI assistance.

## Features

- **Smart Expansion**: Automatically determines how to handle your instruction
- **Intent Memory**: Set a session goal, all expansions align with it
- **Rollback Points**: Auto git stash before code modifications
- **Smart Suggestions**: Suggests next steps after task completion
- **Project Awareness**: Detects tech stack and adjusts accordingly

## Installation

### One-click Install

```bash
curl -fsSL https://raw.githubusercontent.com/ThendCN/prompt-expander/main/install.sh | bash
```

### Manual Install

1. Clone this repo
2. Copy files to `~/.claude/`:
   - `expand.md` → `~/.claude/commands/`
   - `expand-prompt.sh` → `~/.claude/hooks/`
   - `SKILL.md` + `scripts/` + `data/` → `~/.claude/skills/prompt-expander/`
3. Add hooks to `~/.claude/settings.json`:
```json
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
```
4. Restart Claude Code

## Usage

| Prefix | Function |
|--------|----------|
| `*` | Smart expand (auto-detect handling) |
| `**` | Expand and execute directly |
| `*goal:` | Set session intent |
| `*目标:` | Set session intent (Chinese) |

### Examples

```
* add login feature
```
→ Enters dialogue mode, asks clarifying questions, then executes

```
** list files
```
→ Expands and executes immediately

```
*goal: refactoring user module
* add validation
```
→ Expansion considers the refactoring context

## How It Works

1. **Simple & Clear** → Expands directly, copies to clipboard
2. **Ambiguous** → Asks 1-2 clarifying questions
3. **Complex Task** → Enters dialogue mode, refines step by step
4. **Multiple Approaches** → Lists options for you to choose

When you say "ok", "done", "start", "go" in dialogue mode → Executes directly

## Requirements

- Claude Code CLI
- `jq` (for JSON processing)
- macOS (uses `pbcopy` for clipboard)

## Uninstall

```bash
rm -rf ~/.claude/skills/prompt-expander
rm ~/.claude/hooks/expand-prompt.sh
rm ~/.claude/commands/expand.md
# Manually remove hooks from ~/.claude/settings.json
```

## License

MIT
