---
name: prompt-expander
description: 自动识别并扩展简短指令。当用户输入简短、模糊或不完整的指令时自动激活，帮助用户将想法转化为清晰的执行指令。
---

# 指令扩展器

## 触发方式
- `*` 前缀：智能扩展
- `**` 前缀：扩展并直接执行
- `*目标:` 或 `*intent:` 设置会话意图
- 无前缀：Skill 自动判断是否需要扩展

## 智能判断处理方式

根据指令特点自动选择：

| 情况 | 处理方式 |
|------|----------|
| 简单明确 | 直接补全，复制到剪贴板 |
| 有歧义 | 问 1-2 个问题澄清 |
| 复杂任务 | 进入对话模式，逐步细化 |
| 多种方案 | 列出方案让用户选择 |

## 对话模式

当进入对话模式后：
- 通过对话逐步澄清需求
- 用户说"好了"/"可以了"/"开始"/"执行"时，直接开始执行
- 不需要再复制到剪贴板确认

## 项目感知

扩展前快速分析项目：
- 检查 `package.json`、`requirements.txt`、`go.mod` 等识别技术栈
- 根据项目类型调整扩展内容

## 输出要求

简单扩展时：
- 复制到剪贴板：`echo "内容" | pbcopy`
- 告知用户可以 Cmd+V 粘贴

对话模式确认后：
- 直接开始执行，不需要复制确认

## 意图记忆

用户可以设置当前会话的目标/意图：
- 输入 `*目标: xxx` 或 `*intent: xxx` 设置意图
- 设置后，所有扩展都围绕这个意图优化
- 意图存储在 `~/.claude/skills/prompt-expander/data/intent.json`

设置意图：
```bash
echo '{"intent": "用户设置的意图", "setAt": "时间戳"}' > ~/.claude/skills/prompt-expander/data/intent.json
```

读取意图：
```bash
cat ~/.claude/skills/prompt-expander/data/intent.json
```

扩展时参考意图，让扩展结果更贴合用户当前的工作重点。

## 回滚点

执行可能修改代码的操作前：
1. 检查当前目录是否是 git 仓库
2. 如果是，先执行 `git stash push -m "prompt-expander-backup-$(date +%s)"` 创建回滚点
3. 告知用户已创建回滚点
4. 如果用户不满意，可以用 `git stash pop` 回滚

回滚命令：
```bash
git stash list                    # 查看回滚点
git stash pop                     # 恢复最近的回滚点
git stash drop stash@{0}          # 删除回滚点（确认不需要时）
```

## 智能续写

任务完成后，根据上下文建议下一步操作：
- 分析刚完成的任务
- 推荐相关的后续操作
- 用户可以选择执行或忽略
