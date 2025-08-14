if [ -n "${ZSH_VERSION-}" ]; then
  eval 'location=${${(%):-%x}:A:h}'
elif [ -n "${BASH_VERSION-}" ]; then
  location=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
else
  location=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
fi

# load functions
for file in "$location"/functions/*.sh; do
  [ -f "$file" ] && [ -s "$file" ] && . "$file"
done

# cleanup
unset location file
