#!/usr/bin/env bash
# kb-review-cron.sh — 每周由 launchd 调用。
# 流程：刷新 B 类事实 → 若存在「未策展仓库」才唤起 headless claude 起草建议到
# ~/.claude/kb/_proposed.md（draft 模式，不改 KNOWLEDGE_BASE.md）。没缺口就跳过、不花 token。
# 产出供你下次开会话时由 SessionStart 提示、用 /kb-review 审核应用。
export HOME="/Users/yxj"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
CLAUDE_BIN="/Users/yxj/.local/bin/claude"
LOG="$HOME/.claude/kb/_cron.log"
ts() { date '+%Y-%m-%d %H:%M:%S'; }

echo "[$(ts)] kb-review-cron start" >> "$LOG"
bash "$HOME/.claude/kb-sync.sh" >> "$LOG" 2>&1

gaps="$(grep -c . "$HOME/.claude/kb/_gaps.txt" 2>/dev/null || true)"; gaps="${gaps:-0}"
if [ "$gaps" -eq 0 ]; then
  echo "[$(ts)] no curation gaps -> skip claude (0 token)" >> "$LOG"
  exit 0
fi

echo "[$(ts)] $gaps gap(s) -> headless claude /kb-review --draft" >> "$LOG"
# draft 模式只写 _proposed.md；--dangerously-skip-permissions 用于无人值守（本机、自有仓库、仅起草）
"$CLAUDE_BIN" -p "/kb-review --draft" --dangerously-skip-permissions >> "$LOG" 2>&1
rc=$?
echo "[$(ts)] claude done (exit $rc)" >> "$LOG"
exit 0
