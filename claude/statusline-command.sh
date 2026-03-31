#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# user@host
user=$(whoami)
host=$(hostname -s)

# directory: truncate long paths with ellipsis, similar to starship truncation_length=10
dir=$(echo "$cwd" | sed "s|$HOME|~|")
# count path components
components=$(echo "$dir" | tr -cd '/' | wc -c | tr -d ' ')
if [ "$components" -gt 10 ]; then
  dir="…/$(echo "$dir" | rev | cut -d'/' -f1-10 | rev)"
fi

# git branch
branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# time
time_str=$(date +%H:%M:%S)

# context
ctx=""
if [ -n "$remaining" ]; then
  ctx=" ctx:${remaining}%"
fi

# assemble
line="${user}@${host} ${dir}"
if [ -n "$branch" ]; then
  line="${line} ${branch}"
fi
if [ -n "$model" ]; then
  line="${line} | ${model}"
fi
line="${line} [${time_str}]${ctx}"

printf '%s' "$line"
