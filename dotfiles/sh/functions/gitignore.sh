# gitignore.io API function
gi() {
    if [ $# -eq 0 ]; then
        echo "Usage: gi <templates...>"
        echo "Example: gi macos,linux,windows,python,node"
        echo "List available templates: gi list"
        return 1
    fi

    if [ "$1" = "list" ]; then
        curl -sL https://www.gitignore.io/api/list
        return 0
    fi

    curl -sLw "\n" "https://www.gitignore.io/api/$*"
}
