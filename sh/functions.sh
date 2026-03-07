# load functions from the functions subdirectory
for file in "$(dirname "$0")"/functions/*.sh; do
  [ -f "$file" ] && [ -s "$file" ] && . "$file"
done

# cleanup
unset file
