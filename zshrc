files=(
  ~/.sh/env.sh
  ~/.env.local
  ~/.sh/zsh/antigenrc.zsh
  ~/.sh/functions.sh
  ~/.sh/aliases.sh
  ~/.sh/zsh/aliases.zsh
  ~/.zshrc.local
  ~/.aliases.local
)

for file in "${files[@]}"; do
  [[ -s $file ]] && source "$file"
done
