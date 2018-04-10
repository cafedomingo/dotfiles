files=(
  ~/.sh/env.sh
  ~/.env.local
  ~/.sh/functions.sh
  ~/.sh/zsh/antigenrc.zsh
  ~/.sh/zsh/aliases.zsh
  ~/.sh/aliases.sh
  ~/.zshrc.local
  ~/.aliases.local
)

for file in ${files[@]}; do
  [[ -s $file ]] && source $file
done
