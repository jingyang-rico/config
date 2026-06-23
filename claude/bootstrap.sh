#!/usr/bin/env bash
# bootstrap.sh — 在一台新 Mac 上，把本 repo 里策展的 KB 文件软链到 ~/.claude/。
#
# 用法：
#   git clone git@github.com:jingyang-rico/config.git ~/Work/config   # 路径可自定
#   bash ~/Work/config/claude/bootstrap.sh
#
# 做的事（幂等，可重复跑）：
#   1. 把 4 个 A 类源文件软链到 ~/.claude/（已存在的真身会备份成 *.bak.<时间戳>）
#   2. 跑一次 kb-sync.sh 重建本机的 B 类事实快照（~/.claude/kb/，脚本自建）
# 不做的事：launchd 每周定时任务（见末尾说明，按本机情况手动启用）。
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # = <repo>/claude
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date '+%Y%m%d-%H%M%S')"
FILES=(KNOWLEDGE_BASE.md CLAUDE.md kb-sync.sh kb-review-cron.sh)

mkdir -p "$CLAUDE_DIR"
echo "源(repo): $SRC_DIR"
echo "目标:     $CLAUDE_DIR"
echo

for f in "${FILES[@]}"; do
  src="$SRC_DIR/$f"; dst="$CLAUDE_DIR/$f"
  [ -e "$src" ] || { echo "✗ 缺源文件 $src，跳过"; continue; }
  if [ -L "$dst" ]; then
    rm "$dst"                                   # 旧软链：直接替换
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak.$STAMP"                 # 已有真身：备份后再链
    echo "  备份 $f -> $f.bak.$STAMP"
  fi
  ln -s "$src" "$dst"
  echo "✓ $dst -> $src"
done

echo
echo "重建 B 类事实快照 (kb-sync)..."
KB_WORK_DIR="${KB_WORK_DIR:-/Users/yxj/Work}"   # 新机若工作目录不同，先 export KB_WORK_DIR=... 再跑本脚本
echo "  扫描目录 = $KB_WORK_DIR"
[ -d "$KB_WORK_DIR" ] || echo "  ⚠️ $KB_WORK_DIR 不存在；缺口报告会是空的。改用别的目录请 export KB_WORK_DIR=<你的工作目录> 后重跑。"
KB_WORK_DIR="$KB_WORK_DIR" bash "$CLAUDE_DIR/kb-sync.sh" || true

cat <<EOF

✅ 完成。~/.claude 下 4 个 KB 文件已软链到 repo，改完直接在 repo 里 git commit/push 即同步。

可选：每周自动起草（launchd）——仅在你想让"这台"机器跑定时审查时做，且需先满足 claude CLI 已登录：
  • kb-review-cron.sh 第 6/8 行的 HOME / CLAUDE_BIN 是绝对路径，本机用户名/claude 路径若不同需先改。
  • plist 模板见公司机另一台的 ~/Library/LaunchAgents/com.yxj.kb-review.plist，按本机路径改后:
      launchctl load ~/Library/LaunchAgents/com.yxj.kb-review.plist
EOF
