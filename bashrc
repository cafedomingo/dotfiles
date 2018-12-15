files=(
  ~/.sh/env.sh
  ~/.env.local
  ~/.sh/functions.sh
  ~/.sh/aliases.sh
  ~/.sh/bash/colors.bash
  ~/.sh/bash/aliases.bash
  ~/.sh/bash/completion.bash
  ~/.sh/bash/prompt.bash
  ~/.bashrc.local
  ~/.aliases.local
)

for file in "${files[@]}"; do
  [[ -s $file ]] && source "$file"
done
