#!/bin/bash
# 记录反馈到 feedback.json
# 用法: ./record-feedback.sh "原始指令" "扩展结果" "good|bad|modified" ["修改内容"]

FEEDBACK_FILE=~/.claude/skills/prompt-expander/data/feedback.json

original="$1"
expanded="$2"
rating="$3"
modified="${4:-}"
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 创建新反馈条目
new_entry=$(cat << EOF
{
  "original": "$original",
  "expanded": "$expanded",
  "rating": "$rating",
  "modified": "$modified",
  "timestamp": "$timestamp"
}
EOF
)

# 追加到 history 数组
jq --argjson entry "$new_entry" '.history += [$entry]' "$FEEDBACK_FILE" > tmp.json && mv tmp.json "$FEEDBACK_FILE"

echo "✅ 反馈已记录"
