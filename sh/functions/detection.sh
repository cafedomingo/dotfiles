# command detection
has() {
  command -v "$1" >/dev/null 2>&1
}

has_homebrew() {
  has brew
}

# os detection
is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

# cpu architecture detection
get_arch() {
  uname -m
}

is_arm() {
  case "$(get_arch)" in
    *arm*|*aarch*) return 0 ;;
    *) return 1 ;;
  esac
}

is_x86() {
  case "$(get_arch)" in
    *86*) return 0 ;;
    *) return 1 ;;
  esac
}

is_riscv() {
  case "$(get_arch)" in
    *riscv*|rv32*|rv64*) return 0 ;;
    *) return 1 ;;
  esac
}

is_32bit() {
  case "$(get_arch)" in
    *32*) return 0 ;;           # anything with "32" in the name
    i386|i686|x86|armv*) return 0 ;;  # legacy 32-bit names without "32"
    *) return 1 ;;
  esac
}

is_64bit() {
  case "$(get_arch)" in
    *64*) return 0 ;;           # anything with "64" in the name
    *) return 1 ;;
  esac
}

# shell detection
current_shell() {
  [ -n "${SHELL-}" ] || return 1
  printf %s "${SHELL##*/}"
}

is_zsh() {
  [ "$(current_shell)" = "zsh" ]
}

is_bash() {
  [ "$(current_shell)" = "bash" ]
}
