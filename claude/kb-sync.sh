#!/usr/bin/env bash
# kb-sync.sh — 重新生成知识库的「B 类」可派生 git 事实。
#
# 扫描 WORK_DIR 下所有 git 仓库，输出一份带时间戳的快照 + 漂移报告到
# ~/.claude/kb/repos.generated.md。策展的「A 类」内容在 ~/.claude/KNOWLEDGE_BASE.md，
# 本脚本【绝不】触碰它。触发方式（SessionStart hook / launchd / Mac scheduled task /
# 手动）与本脚本解耦——谁来调都行。
#
# 用法: bash ~/.claude/kb-sync.sh
set -euo pipefail
export LC_ALL=C   # 固定排序规则：sort/comm 跨环境（交互 shell vs launchd C locale）结果一致，避免 drift 误报

WORK_DIR="${KB_WORK_DIR:-/Users/yxj/Work}"
OUT_DIR="${KB_OUT_DIR:-$HOME/.claude/kb}"
OUT="$OUT_DIR/repos.generated.md"
PREV="$OUT_DIR/.repos.prev"        # 上次的 "name<TAB>remote"，用于漂移检测
KB="${KB_CURATED:-$HOME/.claude/KNOWLEDGE_BASE.md}"   # A 类策展文档，用于缺口检测
GAPS="$OUT_DIR/_gaps.txt"          # 未策展仓库清单（供 SessionStart 提示 / kb-review 读取）
mkdir -p "$OUT_DIR"

ts="$(date '+%Y-%m-%d %H:%M:%S %Z')"

# ---- 采集：name \t remote \t default \t current \t common_git_dir \t last_commit ----
tsv="$(
  find "$WORK_DIR" -maxdepth 1 -mindepth 1 -type d | sort | while IFS= read -r d; do
    git -C "$d" rev-parse --git-dir >/dev/null 2>&1 || continue
    name="$(basename "$d")"
    remote="$(git -C "$d" remote get-url origin 2>/dev/null || echo '-')"
    cur="$(git -C "$d" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-')"
    def="$(git -C "$d" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's#refs/remotes/origin/##')"
    [ -z "$def" ] && def='-'
    common="$(git -C "$d" rev-parse --git-common-dir 2>/dev/null || echo '-')"
    [ "${common#/}" = "$common" ] && common="$d/$common"   # 相对路径则补成绝对（避开 bash3.2 在 $() 内的 case 解析 bug）
    last="$(git -C "$d" log -1 --format=%cd --date=short 2>/dev/null || echo '-')"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$remote" "$def" "$cur" "$common" "$last"
  done
)"

repo_count="$(printf '%s\n' "$tsv" | grep -c . || true)"

# ---- 漂移检测：对比 name\tremote 集合 ----
new_set="$(printf '%s\n' "$tsv" | awk -F'\t' 'NF{print $1"\t"$2}' | sort)"
added=""; removed=""
if [ -f "$PREV" ]; then
  added="$(comm -13 "$PREV" <(printf '%s\n' "$new_set") || true)"
  removed="$(comm -23 "$PREV" <(printf '%s\n' "$new_set") || true)"
fi

# ---- 生成 markdown ----
{
  echo "<!-- ⚠️ 自动生成，请勿手改。由 ~/.claude/kb-sync.sh 维护。"
  echo "     这是「B 类」可派生 git 事实快照；策展知识在 ~/.claude/KNOWLEDGE_BASE.md。"
  echo "     「当前分支 / 最新 commit」是 C 类易变信息，下表仅为快照，以 \`git\` 现查为准。 -->"
  echo
  echo "# repos.generated.md — git 事实快照（自动生成）"
  echo
  echo "- **生成时间**：$ts"
  echo "- **扫描目录**：\`$WORK_DIR\`"
  echo "- **git 仓库数**：$repo_count"
  echo

  # 漂移报告
  if [ -n "$added$removed" ]; then
    echo "## ⚠️ 漂移（与上次相比）"
    echo
    if [ -n "$added" ]; then
      echo "**新增仓库**（需在 KNOWLEDGE_BASE.md 补策展说明）："
      printf '%s\n' "$added" | awk -F'\t' 'NF{print "- `"$1"` → "$2}'
      echo
    fi
    if [ -n "$removed" ]; then
      echo "**消失仓库**（确认是否已删/改名，更新 KNOWLEDGE_BASE.md）："
      printf '%s\n' "$removed" | awk -F'\t' 'NF{print "- `"$1"` (was "$2")"}'
      echo
    fi
  else
    echo "## 漂移：无（与上次扫描一致）"
    echo
  fi

  # 仓库清单
  echo "## 仓库清单"
  echo
  echo "| 本地目录 | 远程 | 默认分支 | 当前分支(快照) | 最近提交 |"
  echo "|---|---|---|---|---|"
  printf '%s\n' "$tsv" | awk -F'\t' 'NF{print "| `"$1"` | "$2" | "$3" | "$4" | "$6" |"}'
  echo

  # worktree 分组：按 common git dir 聚合，>1 即为 worktree 家族
  echo "## worktree 家族（共享同一 .git）"
  echo
  echo "> ⚠️ 同一分支不能在两个 worktree 同时 checkout。"
  echo
  wt="$(printf '%s\n' "$tsv" | awk -F'\t' 'NF{print $5"\t"$1}' | sort \
    | awk -F'\t' '{a[$1]=a[$1]" "$2; c[$1]++} END{for(k in a) if(c[k]>1) print c[k]"\t"k"\t"a[k]}' | sort -rn)"
  if [ -n "$wt" ]; then
    printf '%s\n' "$wt" | while IFS=$'\t' read -r cnt dir members; do
      echo "- ($cnt) \`$dir\` →${members}"
    done
  else
    echo "（无 worktree）"
  fi
  echo

  # 多克隆：同一 remote 出现在多个不同 common dir
  echo "## 同一远程的多份独立克隆"
  echo
  # 只看「主 checkout」（.git 就在自身目录下，非 worktree）；同一 remote 有 ≥2 个主 checkout 才算多克隆
  mc="$(printf '%s\n' "$tsv" | awk -F'\t' -v wd="$WORK_DIR" \
    'NF && $5==wd"/"$1"/.git" {r[$2]=r[$2]" "$1; c[$2]++} END{for(k in r) if(c[k]>1) print k"\t"r[k]}')"
  if [ -n "$mc" ]; then
    printf '%s\n' "$mc" | while IFS=$'\t' read -r remote members; do
      echo "- $remote →${members}"
    done
  else
    echo "（无）"
  fi
} > "$OUT"

# 更新漂移基线
printf '%s\n' "$new_set" > "$PREV"

# ---- 策展缺口：B 类快照里的仓库，A 类 KNOWLEDGE_BASE.md 未以 `name` 引用 ----
bt='`'
gaps=""
if [ -f "$KB" ]; then
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    grep -qF "$bt$name$bt" "$KB" || gaps="$gaps$name"$'\n'
  done < <(printf '%s\n' "$tsv" | awk -F'\t' -v wd="$WORK_DIR" 'NF && $5==wd"/"$1"/.git"{print $1}')   # 只看主 checkout，排除 worktree
fi
printf '%s' "$gaps" | grep -v '^$' > "$GAPS" 2>/dev/null || : > "$GAPS"
n_gap="$(grep -c . "$GAPS" 2>/dev/null || true)"; n_gap="${n_gap:-0}"

{
  echo
  echo "## 策展缺口（B 类有、A 类 KNOWLEDGE_BASE.md 未提及）"
  echo
  if [ "$n_gap" -gt 0 ]; then
    echo "> 这些仓库还没策展说明，跑 /kb-review 补充："
    grep -v '^$' "$GAPS" | sed "s/^/- $bt/;s/\$/$bt/"
  else
    echo "（无：所有仓库都已策展）"
  fi
} >> "$OUT"

# stdout 摘要（供 hook / scheduled task 抓取）
n_add="$(printf '%s\n' "$added" | grep -c . || true)"
n_rm="$(printf '%s\n' "$removed" | grep -c . || true)"
echo "kb-sync: $repo_count repos, +$n_add new, -$n_rm removed, $n_gap uncurated -> $OUT"
