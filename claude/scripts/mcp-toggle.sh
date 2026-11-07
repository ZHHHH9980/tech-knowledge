#!/usr/bin/env bash
# MCP server 启停开关。
#
# 背景：Claude Code 没有 disable 命令，user-scope 的 MCP server 只能 add / remove。
# 每个 server 的工具 schema 在会话启动时全量注入 context（figma + chrome-devtools
# 合计约 30k tokens），不用的时候关掉能省下这部分。
#
# 做法：把 server 配置从 ~/.claude.json 的 .mcpServers 挪到 ~/.claude/mcp-disabled.json，
# 需要时再挪回去。配置原样保留，不会丢。
#
# 用法：
#   mcp-toggle.sh status          查看启用 / 停用状态
#   mcp-toggle.sh off figma       停用（挪到 stash）
#   mcp-toggle.sh on figma        启用（从 stash 挪回）
#   mcp-toggle.sh off all         停用全部
#   mcp-toggle.sh on all          启用全部
#
# 改完必须重启 Claude Code —— MCP 只在会话启动时读配置。

set -euo pipefail

CONFIG="$HOME/.claude.json"
STASH="$HOME/.claude/mcp-disabled.json"
BACKUP_DIR="$HOME/.claude/.mcp-toggle-backups"

command -v jq >/dev/null || { echo "需要 jq" >&2; exit 1; }
[ -f "$CONFIG" ] || { echo "找不到 $CONFIG" >&2; exit 1; }
[ -f "$STASH" ] || echo '{}' > "$STASH"

# ~/.claude.json 是 Claude Code 的实时状态文件（会话计数、项目历史都在里面）。
# 每次改动前留一份带时间戳的备份，只保留最近 10 份。
backup_config() {
  mkdir -p "$BACKUP_DIR"
  cp "$CONFIG" "$BACKUP_DIR/claude.json.$(date +%Y%m%d-%H%M%S)"
  ls -1t "$BACKUP_DIR"/claude.json.* 2>/dev/null | tail -n +11 | xargs -r rm -f
}

# 写入走临时文件 + mv，避免中途失败留下半个文件。
write_json() {
  local target="$1" content="$2" tmp
  tmp=$(mktemp "${target}.tmp.XXXXXX")
  printf '%s' "$content" > "$tmp"
  jq -e . "$tmp" >/dev/null || { rm -f "$tmp"; echo "生成的 JSON 无效，已中止" >&2; exit 1; }
  mv "$tmp" "$target"
}

cmd_status() {
  local active stashed
  active=$(jq -r '.mcpServers // {} | keys[]' "$CONFIG" 2>/dev/null || true)
  stashed=$(jq -r 'keys[]' "$STASH" 2>/dev/null || true)

  echo "启用中（占用 context）:"
  if [ -n "$active" ]; then
    while IFS= read -r s; do
      echo "  ● $s  $(jq -r --arg s "$s" '.mcpServers[$s].type // "stdio"' "$CONFIG")"
    done <<< "$active"
  else
    echo "  (无)"
  fi

  echo "已停用（零 context 成本）:"
  if [ -n "$stashed" ]; then
    while IFS= read -r s; do
      echo "  ○ $s  $(jq -r --arg s "$s" '.[$s].type // "stdio"' "$STASH")"
    done <<< "$stashed"
  else
    echo "  (无)"
  fi
}

cmd_off() {
  local name="$1" targets
  if [ "$name" = "all" ]; then
    targets=$(jq -r '.mcpServers // {} | keys[]' "$CONFIG")
    [ -n "$targets" ] || { echo "没有启用中的 server"; return; }
  else
    jq -e --arg n "$name" '.mcpServers[$n]' "$CONFIG" >/dev/null 2>&1 \
      || { echo "'$name' 不在启用列表里。跑 status 看看。" >&2; exit 1; }
    targets="$name"
  fi

  backup_config
  while IFS= read -r s; do
    local cfg
    cfg=$(jq -c --arg n "$s" '.mcpServers[$n]' "$CONFIG")
    write_json "$STASH"  "$(jq --arg n "$s" --argjson c "$cfg" '.[$n] = $c' "$STASH")"
    write_json "$CONFIG" "$(jq --arg n "$s" 'del(.mcpServers[$n])' "$CONFIG")"
    echo "已停用 $s"
  done <<< "$targets"
  echo
  echo "重启 Claude Code 生效。"
}

cmd_on() {
  local name="$1" targets
  if [ "$name" = "all" ]; then
    targets=$(jq -r 'keys[]' "$STASH")
    [ -n "$targets" ] || { echo "stash 里没有 server"; return; }
  else
    jq -e --arg n "$name" '.[$n]' "$STASH" >/dev/null 2>&1 \
      || { echo "'$name' 不在 stash 里。跑 status 看看。" >&2; exit 1; }
    targets="$name"
  fi

  backup_config
  while IFS= read -r s; do
    local cfg
    cfg=$(jq -c --arg n "$s" '.[$n]' "$STASH")
    write_json "$CONFIG" "$(jq --arg n "$s" --argjson c "$cfg" '.mcpServers[$n] = $c' "$CONFIG")"
    write_json "$STASH"  "$(jq --arg n "$s" 'del(.[$n])' "$STASH")"
    echo "已启用 $s"
  done <<< "$targets"
  echo
  echo "重启 Claude Code 生效。"
}

case "${1:-status}" in
  status)  cmd_status ;;
  off)     [ $# -ge 2 ] || { echo "用法: $0 off <name|all>" >&2; exit 1; }; cmd_off "$2" ;;
  on)      [ $# -ge 2 ] || { echo "用法: $0 on <name|all>" >&2; exit 1; }; cmd_on "$2" ;;
  *)       sed -n '2,25p' "$0" | sed 's|^# \?||'; exit 1 ;;
esac
