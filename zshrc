files=(
  ~/.sh/env.sh
  ~/.env.local
  ~/.sh/functions.sh
  ~/.sh/zsh/antigenrc.zsh
  ~/.sh/aliases.sh
  ~/.aliases.local
  ~/.sh/zsh/aliases.zsh
  ~/.zshrc.local
)

for file in ${files[@]}; do
  [[ -s $file ]] && source $file
done
