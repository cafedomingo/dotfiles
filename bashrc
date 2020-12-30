files=(
  ~/.sh/env.sh
  ~/.env.local
  ~/.sh/bash/colors.bash
  ~/.sh/bash/options.bash
  ~/.sh/bash/completions.bash
  ~/.sh/bash/prompt.bash
  ~/.sh/functions.sh
  ~/.sh/aliases.sh
  ~/.sh/bash/aliases.bash
  ~/.bashrc.local
  ~/.aliases.local
)

for file in "${files[@]}"; do
  [[ -s $file ]] && source "$file"
done
