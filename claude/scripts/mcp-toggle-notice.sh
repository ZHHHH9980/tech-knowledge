#!/usr/bin/env bash
# SessionStart hook：把「哪些 MCP server 被手动停用了」告诉 Claude。
#
# 没有这个提示，agent 只会发现 figma / chrome-devtools 工具不存在，
# 然后误判成「环境坏了」或者「这事做不了」，而实际上只是为了省 context 关掉了，
# 一条命令就能开回来。
#
# 由 ~/.claude/settings.json 的 SessionStart 注册。stash 为空时不输出。

STASH="$HOME/.claude/mcp-disabled.json"

[ -f "$STASH" ] || exit 0
command -v jq >/dev/null || exit 0

names=$(jq -r 'keys | join(", ")' "$STASH" 2>/dev/null)
[ -n "$names" ] && [ "$names" != "null" ] || exit 0

cat <<EOF
[mcp-toggle] 已手动停用的 MCP server：${names}
  这些 server 的工具本次会话不可用。不是故障——是为省 context 主动关的
  （每个 server 的工具 schema 会全量注入，figma + chrome-devtools 约 30k tokens）。
  需要时告诉用户跑：~/.claude/mcp-toggle.sh on <name>（或 on all），然后重启 Claude Code。
  查看状态：~/.claude/mcp-toggle.sh status
  不要试图绕过缺失的工具去自己实现等价能力，也不要报告成环境问题。
EOF
