#!/bin/bash
input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // ""')

INTENT_FILE=~/.claude/skills/prompt-expander/data/intent.json

# Set intent
if [[ "$prompt" == \*目标:* ]] || [[ "$prompt" == \*intent:* ]] || [[ "$prompt" == \*goal:* ]]; then
    if [[ "$prompt" == \*目标:* ]]; then
        intent="${prompt#*目标:}"
    elif [[ "$prompt" == \*goal:* ]]; then
        intent="${prompt#*goal:}"
    else
        intent="${prompt#*intent:}"
    fi
    intent="${intent#"${intent%%[![:space:]]*}"}"
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "{\"intent\": \"$intent\", \"setAt\": \"$timestamp\"}" > "$INTENT_FILE"

    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "User set session intent: $intent\n\nConfirm recorded. All subsequent expansions should align with this intent."
  }
}
EOF

elif [[ "$prompt" == \*\** ]]; then
    # ** mode: expand and execute
    short_prompt="${prompt:2}"
    short_prompt="${short_prompt#"${short_prompt%%[![:space:]]*}"}"

    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "User input a short instruction. Expand and execute directly.\n\nOriginal: $short_prompt\n\nStart your response with [⚡ Quick Execute] to indicate quick execution mode.\n\nRequirements:\n1. Briefly explain your understanding\n2. Execute immediately\n3. No confirmation needed"
  }
}
EOF

elif [[ "$prompt" == \** ]]; then
    # * mode: smart expand
    short_prompt="${prompt:1}"
    short_prompt="${short_prompt#"${short_prompt%%[![:space:]]*}"}"

    # Read intent
    intent=""
    if [[ -f "$INTENT_FILE" ]]; then
        intent=$(jq -r '.intent // ""' "$INTENT_FILE" 2>/dev/null)
    fi

    intent_context=""
    if [[ -n "$intent" ]]; then
        intent_context="\\n\\nCurrent session intent: $intent\\nAlign expansion with this intent."
    fi

    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "User input a short instruction. Smart expand it.\n\nOriginal: $short_prompt$intent_context\n\nStart your response with [🔄 Expanding] to indicate expansion mode is active.\n\nChoose handling based on complexity:\n1. Simple & clear → Expand directly, copy to clipboard\n2. Ambiguous → Ask 1-2 clarifying questions\n3. Complex task → Enter dialogue mode, refine step by step\n4. Multiple approaches → List options for user to choose\n\nWhen user says \"ok\", \"done\", \"start\", \"go\" → Execute directly.\n\nBefore modifying code in a git repo, create rollback point with git stash.\n\nAfter task completion, suggest related next steps."
  }
}
EOF
fi

exit 0
