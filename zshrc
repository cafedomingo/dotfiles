files=(
  ~/.sh/env.sh
  ~/.env.local
  ~/.sh/functions.sh
  ~/.sh/zsh/antigenrc.zsh
  ~/.sh/aliases.sh
  ~/.sh/zsh/aliases.zsh
  ~/.aliases.local
  ~/.zshrc.local
)

for file in ${files[@]}; do
  [[ -s $file ]] && source $file
done
