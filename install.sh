#!/usr/bin/env bash

set -euo pipefail

# colors for output
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly GREEN='\033[92m'
readonly BLUE='\033[94m'
readonly RED='\033[91m'
readonly YELLOW='\033[93m'

# global settings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/install.conf"
DRY_RUN=false
VERBOSE=false

# indentation for sub-items (adjust this to control alignment)
readonly SUB_INDENT="  "

# default options
declare -A DEFAULTS=(
    ["link_relink"]="false"
    ["link_create"]="false"
    ["link_force"]="false"
    ["clean_force"]="false"
    ["clean_recursive"]="false"
    ["create_mode"]="755"
)

# ============================================================================
# logging and utility functions
# ============================================================================

# simple, readable logging functions
log() {
    echo -e "${SUB_INDENT}${1}${2}${RESET} ${3}" ${4:+>&2}
}

header() {
    echo
    echo -e "${BOLD}${1}==>${RESET} ${2}"
}

log_info() {
    local symbol="✓"
    [[ "$DRY_RUN" == "true" ]] && symbol="◦"
    log "$BLUE" "$symbol" "$*"
}

log_debug() {
    [[ "$VERBOSE" == "true" ]] && log "$BLUE" "•" "$*" || return 0
}

log_warning() {
    log "$YELLOW" "⚠" "$*"
}

log_error() {
    log "$RED" "✗" "$*" "true"
}

log_step() {
    header "${BLUE}" "$*"
}

log_success() {
    header "${GREEN}" "$*"
}

log_failure() {
    header "${RED}" "$*"
}

# execute a command with dry-run awareness - standard approach
# usage: run_cmd "command" "log_message" [log_function]
run_cmd() {
    local command="$1"
    local message="$2"
    local log_func="${3:-log_info}"

    # execute command only if not dry-run
    if [[ "$DRY_RUN" != "true" && -n "$command" ]]; then
        eval "$command"
    fi

    # always log the message
    $log_func "$message"
}

# ============================================================================
# command line argument parsing
# ============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -c|--config)
                shift
                if [[ $# -gt 0 ]]; then
                    CONFIG_FILE="$1"
                    shift
                else
                    log_error "Configuration file path required after -c/--config"
                    exit 1
                fi
                ;;
            -h|--help)
                cat << 'EOF'
Simple dotfiles installer

Usage: install-bash.sh [options]

Options:
  -v, --verbose      Enable verbose output
  --dry-run          Show what would be done without making changes
  -c, --config FILE  Use specified configuration file
  -h, --help         Show this help message

Configuration format (install.conf):
  DEFAULT directive option=value  # Set defaults for a directive
  CLEAN target [options]          # Remove broken symlinks
  LINK target [options]           # Create symbolic links
  CREATE target [options]         # Create directories
  SHELL command                   # Execute shell commands/scripts

Link options: path=source, create=true/false, relink=true/false, force=true/false
Create options: mode=755 (octal permissions)
Clean options: force=true/false, recursive=true/false
Shell options: stdout=true/false, stderr=true/false, description="text"

Examples:
  install-bash.sh                 # Run with default configuration
  install-bash.sh --dry-run       # Show what would be done
  install-bash.sh -v -c my.conf   # Verbose mode with custom config

EOF
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information." >&2
                exit 1
                ;;
        esac
    done
}

# ============================================================================
# configuration parsing and path utilities
# ============================================================================

# parse key=value parameters from a line
parse_params() {
    local line="$1"
    local -A params

    # remove the command and target (first two words) and parse remaining key=value pairs
    local args="${line#* }"  # remove command
    args="${args#* }"        # remove target

    # split on spaces safely, handle key=value pairs only
    local -a words
    read -ra words <<< "$args"
    for param in "${words[@]}"; do
        if [[ "$param" == *"="* ]]; then
            local key="${param%%=*}"
            local value="${param#*=}"
            params["$key"]="$value"
        fi
    done

    # output as key=value pairs for caller to eval
    for key in "${!params[@]}"; do
        printf '%s=%s\n' "$key" "${params[$key]}"
    done
}

# expand tilde and environment variables in paths
expand_path() {
    local path="$1"

    # handle tilde expansion manually since bash doesn't expand ~ in variables
    if [[ "$path" == "~" ]]; then
        path="$HOME"
    elif [[ "${path:0:2}" == "~/" ]]; then
        path="${HOME}${path:1}"
    fi

    echo "$path"
}

# ============================================================================
# core installation functions
# ============================================================================

# check if a symlink is broken
is_broken_symlink() {
    local path="$1"
    [[ -L "$path" && ! -e "$path" ]]
}

# clean broken symlinks in a directory (optionally recursive)
clean_directory() {
    local target="$1"
    local force="${2:-false}"
    local recursive="${3:-false}"

    target=$(expand_path "$target")

    if [[ ! -d "$target" ]]; then
        log_debug "Ignoring nonexistent directory: $target"
        return 0
    fi

    while IFS= read -r -d '' item; do
        if is_broken_symlink "$item"; then
            # get what the broken symlink points to (resolve relative paths)
            local link_target
            local link_dir="${item%/*}"
            local raw_target
            raw_target=$(readlink "$item")

            # resolve relative symlink targets to absolute paths
            if [[ "$raw_target" == /* ]]; then
                link_target="$raw_target"
            else
                link_target="$link_dir/$raw_target"
            fi

            # check if the symlink target is in our dotfiles directory
            local should_remove=false
            if [[ "$force" == "true" ]]; then
                should_remove=true
            elif [[ "$link_target" == "$SCRIPT_DIR"* ]]; then
                should_remove=true
            fi

            if [[ "$should_remove" == "true" ]]; then
                run_cmd "rm '$item'" "Removing invalid link $item → $raw_target" "echo"
            else
                log_info "Link not removed: $item → $raw_target"
            fi
        elif [[ "$recursive" == "true" && -d "$item" && ! -L "$item" ]]; then
            clean_directory "$item" "$force" "$recursive"
        fi
    done < <(find -L "$target" -mindepth 1 -maxdepth 1 -print0 2>/dev/null || true)

    return 0
}

# create a symbolic link with proper source path resolution
create_symlink() {
    local dest="$1"
    local src="$2"
    local create_dirs="${3:-false}"
    local relink="${4:-false}"
    local force="${5:-false}"

    # determine source path BEFORE expanding destination
    if [[ -z "$src" ]]; then
        # default: remove leading dot from basename of original destination
        local basename="${dest##*/}"
        if [[ "$basename" == .* ]]; then
            src="${basename#.}"
        else
            src="$basename"
        fi
    fi

    # now expand the destination path
    dest=$(expand_path "$dest")

    # make source path absolute relative to script directory
    if [[ "$src" != /* ]]; then
        src="$SCRIPT_DIR/$src"
    fi

    if [[ ! -e "$src" ]]; then
        log_error "Source does not exist: $src"
        return 1
    fi

    # create parent directories if needed
    if [[ "$create_dirs" == "true" ]]; then
        local parent_dir="${dest%/*}"
        if [[ ! -d "$parent_dir" ]]; then
            run_cmd "mkdir -p '$parent_dir'" "Created parent directories for: $dest" "log_debug"
        fi
    fi

    # handle existing destination
    if [[ -L "$dest" ]]; then
        local current_target
        current_target=$(readlink "$dest")
        if [[ "$current_target" == "$src" ]]; then
            log_info "Exists: ${1} → $src"
            return 0
        elif [[ "$relink" == "true" ]]; then
            run_cmd "rm '$dest'" "Removed existing link: $dest" "log_debug"
        else
            log_warning "Link points elsewhere: $dest → $current_target"
            return 1
        fi
    elif [[ -e "$dest" ]]; then
        if [[ "$relink" == "true" || "$force" == "true" ]]; then
            run_cmd "rm -rf '$dest'" "Removed existing file: $dest" "log_debug"
        else
            log_warning "Destination exists and is not a symlink: $dest"
            return 1
        fi
    fi

    # create the symlink
    run_cmd "ln -s '$src' '$dest'" "Created: $dest → ${src#$SCRIPT_DIR/}"
}

# create a directory
create_directory() {
    local path="$1"
    local mode="${2:-755}"
    path=$(expand_path "$path")

    if [[ -d "$path" ]]; then
        log_info "Path exists $path"
        return 0
    fi

    run_cmd "mkdir -p '$path' && chmod '$mode' '$path'" "Created directory: $path (mode: $mode)"
}

# execute a shell command with optional output control
execute_shell_command() {
    local command="$1"
    local description="$2"
    local show_stdout="${3:-false}"
    local show_stderr="${4:-false}"

    # handle dry-run logging
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would execute: $command"
        return 0
    fi

    # show what we're executing (neutral symbol since we don't know outcome yet)
    log "$BLUE" "▶" "Executing: $command"

    # build command with output redirection and indentation
    local full_command="$command"

    # if we're showing output, pipe it through sed to add tree indentation
    if [[ "$show_stdout" == "true" || "$show_stderr" == "true" ]]; then
        # create indentation filter - adds tree symbols to each line
        local indent_filter="sed 's/^/${SUB_INDENT}${SUB_INDENT}│ /'"

        if [[ "$show_stdout" == "true" && "$show_stderr" == "true" ]]; then
            full_command+=" 2>&1 | $indent_filter"
        elif [[ "$show_stdout" == "true" ]]; then
            full_command+=" 2>/dev/null | $indent_filter"
        elif [[ "$show_stderr" == "true" ]]; then
            full_command+=" 2>&1 >/dev/null | $indent_filter"
        fi
    else
        # no output requested
        full_command+=" >/dev/null 2>&1"
    fi

    # execute and log result with tree-like nesting
    if ! eval "$full_command"; then
        # nested failure with tree symbol
        echo -e "${SUB_INDENT}${SUB_INDENT}└─ ${RED}✗${RESET} Failed: $command" >&2
        return 1
    fi

    # nested success with tree symbol
    echo -e "${SUB_INDENT}${SUB_INDENT}└─ ${GREEN}✓${RESET} Success: $command"
}

# process the configuration file line by line
process_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi

    local line_num=0
    local errors=0

    # read each line and process directives
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))

        # skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # extract the command (first word)
        local command="${line%% *}"

        case "$command" in
            DEFAULT)
                # parse default settings
                local directive
                read -r _ directive _ <<< "$line"
                local params
                params=$(parse_params "$line")
                while IFS='=' read -r key value; do
                    [[ -n "$key" && "$key" != "path" ]] && DEFAULTS["${directive,,}_$key"]="$value"
                done <<< "$params"
                log_debug "Set defaults from: $line"
                ;;

            CLEAN)
                if [[ -z "${clean_started:-}" ]]; then
                    log_step "Cleaning broken symbolic links"
                    clean_started=1
                fi

                local params target force recursive
                params=$(parse_params "$line")

                # extract target (first non-key=value argument)
                read -r _ target _ <<< "$line"
                force="${DEFAULTS[clean_force]}"
                recursive="${DEFAULTS[clean_recursive]}"

                # override with line-specific parameters
                while IFS='=' read -r key value; do
                    case "$key" in
                        force) force="$value" ;;
                        recursive) recursive="$value" ;;
                    esac
                done <<< "$params"

                clean_directory "$target" "$force" "$recursive" || ((errors++))
                ;;

            LINK)
                if [[ -z "${link_started:-}" ]]; then
                    log_step "Creating symbolic links"
                    link_started=1
                fi

                local params target src create_dirs relink force
                params=$(parse_params "$line")

                # extract target (first non-key=value argument)
                read -r _ target _ <<< "$line"
                src=""
                create_dirs="${DEFAULTS[link_create]}"
                relink="${DEFAULTS[link_relink]}"
                force="${DEFAULTS[link_force]}"

                # override with line-specific parameters
                while IFS='=' read -r key value; do
                    case "$key" in
                        path) [[ -n "$value" ]] && src="$value" ;;
                        create) create_dirs="$value" ;;
                        relink) relink="$value" ;;
                        force) force="$value" ;;
                    esac
                done <<< "$params"

                create_symlink "$target" "$src" "$create_dirs" "$relink" "$force" || ((errors++))
                ;;

            CREATE)
                if [[ -z "${create_started:-}" ]]; then
                    log_step "Creating directories"
                    create_started=1
                fi

                local params target mode
                params=$(parse_params "$line")

                # extract target (first non-key=value argument)
                read -r _ target _ <<< "$line"
                mode="${DEFAULTS[create_mode]}"

                # override with line-specific parameters
                while IFS='=' read -r key value; do
                    case "$key" in
                        mode) mode="$value" ;;
                    esac
                done <<< "$params"

                create_directory "$target" "$mode" || ((errors++))
                ;;

            SHELL)
                if [[ -z "${shell_started:-}" ]]; then
                    log_step "Executing shell commands"
                    shell_started=1
                fi

                local command_str description stdout stderr

                # extract command - first argument after SHELL
                read -r _ command_str rest <<< "$line"

                # set defaults
                description=""
                stdout="false"
                stderr="false"

                # parse the rest of the line for options
                if [[ -n "$rest" ]]; then
                    # handle description="quoted text" properly
                    if [[ "$rest" == *'description='* ]]; then
                        if [[ "$rest" == *'description="'* ]]; then
                            # extract quoted description
                            description="${rest#*description=\"}"
                            description="${description%%\"*}"
                            # remove description from rest for other parsing
                            local desc_pattern="description=\"$description\""
                            rest="${rest/$desc_pattern/}"
                        else
                            # unquoted description (single word)
                            description="${rest#*description=}"
                            description="${description%% *}"
                        fi
                    fi

                    # parse other options
                    if [[ "$rest" == *'stdout=true'* ]]; then
                        stdout="true"
                    fi
                    if [[ "$rest" == *'stderr=true'* ]]; then
                        stderr="true"
                    fi
                fi

                execute_shell_command "$command_str" "$description" "$stdout" "$stderr" || ((errors++))
                ;;

            *)
                log_warning "Unknown command on line $line_num: $command"
                ;;
        esac

    done < "$CONFIG_FILE"

    return $errors
}

# ============================================================================
# main execution
# ============================================================================

main() {
    parse_args "$@"

    log_step "Loading configuration from $CONFIG_FILE"
    log_debug "Base directory: $SCRIPT_DIR"
    [[ "$DRY_RUN" == "true" ]] && log_debug "Running in dry-run mode"
    if process_config; then
        log_success "All tasks executed successfully"
    else
        log_failure "Some tasks failed"
        exit 1
    fi
}

main "$@"
