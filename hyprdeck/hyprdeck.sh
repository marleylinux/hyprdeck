#!/usr/bin/env bash
set -euo pipefail

# hyprdeck.sh
BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

say() { printf '%s\n' "$*"; }
p() { printf '%s %s\n' "$1" "$2"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

is_root() { [ "${EUID:-$(id -u)}" -eq 0 ]; }

maybe_quit() {
  case "${1,,}" in
    q|quit|exit)
      goodbye "Exited HyprDeck Installer - MarleyLinux"
      ;;
  esac
}

prompt_read() {
  local __var="$1"
  local __prompt="$2"
  local __default="${3-}"
  local __line=""

  if [ -t 0 ] && [ -t 1 ]; then
    read -r -p "$__prompt" __line || true
  else
    if [ -r /dev/tty ]; then
      read -r -p "$__prompt" __line < /dev/tty || true
    else
      read -r __line || true
    fi
  fi

  if [ -z "$__line" ] && [ -n "$__default" ]; then
    __line="$__default"
  fi
  printf -v "$__var" '%s' "$__line"
}

confirm_yes_default() {
  local q="$1"
  local ans=""
  prompt_read ans "$q [Y/n]: " "y"
  case "${ans,,}" in
    y|yes|"") return 0 ;;
    *) return 1 ;;
  esac
}

supports_unicode() {
  case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf8*) return 0 ;;
    *) return 1 ;;
  esac
}

has_noto_emoji() {
  command -v pacman >/dev/null 2>&1 || return 1
  pacman -Q noto-fonts-emoji >/dev/null 2>&1
}

supports_ansi() {
  [ "${NO_COLOR:-0}" = "1" ] && return 1
  [ -t 1 ] || return 1
  [ "${TERM:-}" = "dumb" ] && return 1
  return 0
}

NOTO_PRESENT_AT_START=0
if has_noto_emoji; then NOTO_PRESENT_AT_START=1; fi

USE_EMOJI=0
USE_ANSI=0
USE_UNICODE=0

pick_ui() {
  USE_UNICODE=0
  supports_unicode && USE_UNICODE=1

  USE_EMOJI=0
  if [ "${FORCE_EMOJI:-0}" = "1" ]; then
    USE_EMOJI=1
  elif [ "${NO_EMOJI:-0}" = "1" ]; then
    USE_EMOJI=0
  elif [ "$USE_UNICODE" = "1" ] && [ "${TERM:-}" != "linux" ]; then
    USE_EMOJI=1
  elif [ "${TERM:-}" = "linux" ]; then
    USE_EMOJI=0
  elif [ "${NOTO_PRESENT_AT_START:-0}" = "1" ] && [ "$USE_UNICODE" = "1" ]; then
    USE_EMOJI=1
  fi

  USE_ANSI=0
  if [ "${FORCE_COLOR:-0}" = "1" ]; then
    USE_ANSI=1
  elif supports_ansi; then
    USE_ANSI=1
  fi

  if [ "${FORCE_ASCII:-0}" = "1" ]; then
    USE_EMOJI=0
    USE_ANSI=0
  fi
}

RESET=""
C_RED=""; C_MAG=""; C_BLU=""; C_YEL=""; C_GRN=""

init_ansi() {
  RESET=$'\033[0m'
  C_RED=$'\033[31m'
  C_GRN=$'\033[32m'
  C_YEL=$'\033[33m'
  C_BLU=$'\033[34m'
  C_MAG=$'\033[35m'
}

pick_ui
init_ansi
trap 'printf "%s" "${RESET:-}"' EXIT

if [ "${USE_EMOJI:-0}" = "1" ]; then
  UI_ML="🟪"
  UI_INFO="🟦"
  UI_NOTE="🟨"
  UI_OK="🟩"
  UI_ERR="🟥"

  INNER_LINE="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  cat_line() { local box="$1"; printf '%s%s%s\n' "$box" "$INNER_LINE" "$box"; }
elif [ "${USE_ANSI:-0}" = "1" ] && [ "${USE_UNICODE:-0}" = "1" ]; then
  UI_ML="${C_MAG}■${RESET}"
  UI_INFO="${C_BLU}■${RESET}"
  UI_NOTE="${C_YEL}■${RESET}"
  UI_OK="${C_GRN}■${RESET}"
  UI_ERR="${C_RED}■${RESET}"

  INNER_LINE="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  cat_line() { local box="$1"; printf '%s%s%s\n' "$box" "$INNER_LINE" "$box"; }
elif [ "${USE_ANSI:-0}" = "1" ]; then
  UI_ML="${C_MAG}[*]${RESET}"
  UI_INFO="${C_BLU}[i]${RESET}"
  UI_NOTE="${C_YEL}[!]${RESET}"
  UI_OK="${C_GRN}[+]${RESET}"
  UI_ERR="${C_RED}[x]${RESET}"

  INNER_LINE="======================================================"
  cat_line() { say "${C_MAG}${INNER_LINE}${RESET}"; }
else
  UI_ML="[*]"
  UI_INFO="[i]"
  UI_NOTE="[!]"
  UI_OK="[+]"
  UI_ERR="[x]"

  INNER_LINE="======================================================"
  cat_line() { say "$INNER_LINE"; }
fi

# Menu “colored boxes”
BOX_PURPLE="$UI_ML"   # Pictures, themes/icons
BOX_BLUE="$UI_INFO"   # hypr, cpupower, MangoHud
BOX_YELLOW="$UI_NOTE" # bash/vim
BOX_GREEN="$UI_OK"    # nwg + greetd + nvim
BOX_RED="$UI_ERR"     # pacman/system warning

goodbye() {
  local msg="${1:-Thanks for using HyprDeck - MarleyLinux}"
  say ""
  cat_line "$UI_ML"
  p "$UI_ML" "$msg"
  cat_line "$UI_ML"
  exit 0
}

header() {
  say ""
  cat_line "$UI_ML"
  p "$UI_ML" "HyprDeck Installer - MarleyLinux"
  cat_line "$UI_ML"
}

section() {
  local box="$1"
  local title="$2"
  say ""
  cat_line "$box"
  p "$box" "$title"
  cat_line "$box"
}

tutorial() {
  section "$UI_ML" "Tutorial: HyprDeck dotfiles (Steam Deck vibe on Arch + Hyprland)"

  p "$UI_NOTE" "How to use:"
  p "$UI_NOTE" "  • Type one or more names (space-separated), or: all"
  p "$UI_NOTE" "  • Type: q  to quit"
  say ""

  p "$UI_ERR"  "WARNING:"
  p "$UI_ERR"  "  This script OVERWRITES targets (no backups)."
  p "$UI_NOTE" "  System paths (/etc, /usr) require sudo."
  say ""

  local tmp=""
  prompt_read tmp "Press Enter to continue (or 'q'): " ""
  maybe_quit "$tmp"
}

# ---------- Current user (no prompt) ----------
if is_root && [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER:-}" != "root" ]; then
  USERNAME="$SUDO_USER"
else
  USERNAME="$(id -un)"
fi

USER_HOME="$(getent passwd "$USERNAME" | awk -F: '{print $6}')"
[ -n "$USER_HOME" ] || die "Could not resolve home for user: $USERNAME"
USER_CONFIG_DIR="$USER_HOME/.config"

HYPRDECK_DIR="${HYPRDECK_ROOT:-}"

detect_hyprdeck_root() {
  local nested="$BASE_DIR/hyprdeck"
  local flat="$BASE_DIR"

  if [ -n "$HYPRDECK_DIR" ]; then
    [ -d "$HYPRDECK_DIR" ] || die "HYPRDECK_ROOT is set but not a directory: $HYPRDECK_DIR"
    printf '%s' "$HYPRDECK_DIR"
    return 0
  fi

  if [ -d "$nested" ]; then
    printf '%s' "$nested"
    return 0
  fi

  if [ -d "$flat/hypr" ] \
    || [ -d "$flat/nwg-panel" ] \
    || [ -d "$flat/nwg-bar" ] \
    || [ -d "$flat/nwg-drawer" ] \
    || [ -d "$flat/nwg-hello" ] \
    || [ -d "$flat/MangoHud" ] \
    || [ -d "$flat/nvim" ] \
    || [ -d "$flat/Pictures" ] \
    || [ -f "$flat/bashrc" ] \
    || [ -f "$flat/vimrc" ] \
    || [ -f "$flat/pacman.conf" ] \
    || [ -f "$flat/cpupower" ] \
    || [ -f "$flat/adw-gtk3v5.6.tar.xz" ] \
    || [ -f "$flat/catppuccin-mocha-dark-cursors.zip" ]; then
    printf '%s' "$flat"
    return 0
  fi

  die "Could not find HyprDeck root.
Expected either:
  - $BASE_DIR/hyprdeck/<stuff>
  - $BASE_DIR/<stuff>
Or set: HYPRDECK_ROOT=/path/to/root"
}

HYPRDECK_DIR="$(detect_hyprdeck_root)"
src_path() { printf '%s/%s' "$HYPRDECK_DIR" "$1"; }

needs_root_for_path() {
  case "$1" in
    /etc/*|/usr/*) return 0 ;;
    *) return 1 ;;
  esac
}

run_for_path() {
  local path="$1"; shift
  if needs_root_for_path "$path"; then
    if is_root; then
      "$@"
    else
      sudo "$@"
    fi
  else
    "$@"
  fi
}

rm_force_for_path() {
  local target="$1"
  run_for_path "$target" rm -rf -- "$target"
}

ensure_dir_for_path() {
  local dir="$1"
  run_for_path "$dir" install -d -m 0755 -- "$dir"
}

copy_file_overwrite_to() {
  local src="$1"
  local dst="$2"

  rm_force_for_path "$dst"
  ensure_dir_for_path "$(dirname -- "$dst")"
  run_for_path "$dst" install -m 0644 -- "$src" "$dst"
}

copy_dir_overwrite_to() {
  local src="$1"
  local dst="$2"

  [ -d "$src" ] || die "Not a dir: $src"
  local parent; parent="$(dirname -- "$dst")"
  ensure_dir_for_path "$parent"
  rm_force_for_path "$dst"

  if command -v rsync >/dev/null 2>&1; then
    run_for_path "$dst" rsync -a -- "$src" "$parent/"
  else
    run_for_path "$dst" cp -a -- "$src" "$parent/"
  fi

  [ -d "$dst" ] || die "Copy failed: $src -> $dst"
}

fix_user_ownership_under_home() {
  local target="$1"
  if is_root && [[ "$target" == "$USER_HOME"* ]]; then
    chown -R "$USERNAME:$USERNAME" -- "$target"
  fi
}

extract_tar_xz_overwrite() {
  local archive="$1"
  local dest="$2"

  [ -f "$archive" ] || die "Missing archive: $archive"
  ensure_dir_for_path "$dest"

  local names=""
  names="$(tar -tf "$archive" | awk -F/ 'NF{print $1}' | sort -u)" || true
  if [ -n "$names" ]; then
    while IFS= read -r n; do
      [ -n "$n" ] || continue
      rm_force_for_path "$dest/$n"
    done <<< "$names"
  fi

  run_for_path "$dest" tar -xJf "$archive" -C "$dest"
}

extract_zip_overwrite() {
  local archive="$1"
  local dest="$2"

  [ -f "$archive" ] || die "Missing archive: $archive"
  ensure_dir_for_path "$dest"

  local names=""
  if command -v unzip >/dev/null 2>&1; then
    names="$(unzip -Z1 "$archive" | awk -F/ 'NF{print $1}' | sort -u)" || true
  elif command -v bsdtar >/dev/null 2>&1; then
    names="$(bsdtar -tf "$archive" | awk -F/ 'NF{print $1}' | sort -u)" || true
  else
    die "Need unzip or bsdtar to extract: $archive"
  fi

  if [ -n "$names" ]; then
    while IFS= read -r n; do
      [ -n "$n" ] || continue
      rm_force_for_path "$dest/$n"
    done <<< "$names"
  fi

  if command -v unzip >/dev/null 2>&1; then
    run_for_path "$dest" unzip -oq "$archive" -d "$dest"
  else
    run_for_path "$dest" bsdtar -xf "$archive" -C "$dest"
  fi
}

install_pictures() {
  local s; s="$(src_path "Pictures")"
  [ -d "$s" ] || die "Missing source dir: $s"
  local d="$USER_HOME/Pictures"

  section "$BOX_PURPLE" "Pictures -> ~/Pictures"
  p "$BOX_PURPLE" "Overwrite: $d"
  copy_dir_overwrite_to "$s" "$d"
  fix_user_ownership_under_home "$d"
  p "$UI_OK" "Installed Pictures"
}

install_bashrc() {
  local s; s="$(src_path "bashrc")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="$USER_HOME/.bashrc"

  section "$BOX_YELLOW" "bashrc -> ~/.bashrc"
  p "$BOX_YELLOW" "Overwrite: $d"
  copy_file_overwrite_to "$s" "$d"
  fix_user_ownership_under_home "$d"
  p "$UI_OK" "Installed bashrc"
}

install_vimrc() {
  local s; s="$(src_path "vimrc")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="$USER_HOME/.vimrc"

  section "$BOX_YELLOW" "vimrc -> ~/.vimrc"
  p "$BOX_YELLOW" "Overwrite: $d"
  copy_file_overwrite_to "$s" "$d"
  fix_user_ownership_under_home "$d"
  p "$UI_OK" "Installed vimrc"
}

install_pacman_conf() {
  local s; s="$(src_path "pacman.conf")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="/etc/pacman.conf"

  section "$BOX_RED" "pacman.conf -> /etc/pacman.conf"
  p "$BOX_RED" "Overwrite: $d"
  copy_file_overwrite_to "$s" "$d"
  p "$UI_OK" "Installed pacman.conf"
}

install_cpupower() {
  local s; s="$(src_path "cpupower")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="/etc/default/cpupower"

  section "$BOX_BLUE" "cpupower -> /etc/default/cpupower"
  p "$BOX_BLUE" "Overwrite: $d"
  copy_file_overwrite_to "$s" "$d"
  p "$UI_OK" "Installed cpupower"
}

install_config_dir() {
  local name="$1"
  local box="${2-}"
  [ -n "$box" ] || box="$UI_INFO"

  local s; s="$(src_path "$name")"
  [ -d "$s" ] || die "Missing source dir: $s"
  local d="$USER_CONFIG_DIR/$name"

  section "$box" "$name -> ~/.config/$name"
  ensure_dir_for_path "$USER_CONFIG_DIR"
  p "$box" "Overwrite: $d"
  copy_dir_overwrite_to "$s" "$d"
  fix_user_ownership_under_home "$d"
  p "$UI_OK" "Installed $name"
}

install_etc_dir() {
  local name="$1"
  local dest="$2"
  local box="${3-}"
  [ -n "$box" ] || box="$UI_INFO"

  local s; s="$(src_path "$name")"
  [ -d "$s" ] || die "Missing source dir: $s"

  section "$box" "$name -> $dest"
  p "$box" "Overwrite: $dest"
  copy_dir_overwrite_to "$s" "$dest"
  p "$UI_OK" "Installed $name"
}

install_greetd()     { install_etc_dir "greetd" "/etc/greetd" "$BOX_GREEN"; }
install_hypr()       { install_config_dir "hypr"       "$BOX_BLUE"; }
install_mangohud()   { install_config_dir "MangoHud"   "$BOX_BLUE"; }
install_nvim()       { install_config_dir "nvim"       "$BOX_GREEN"; }
install_nwg_bar()    { install_config_dir "nwg-bar"    "$BOX_GREEN"; }
install_nwg_drawer() { install_config_dir "nwg-drawer" "$BOX_GREEN"; }
install_nwg_panel()  { install_config_dir "nwg-panel"  "$BOX_GREEN"; }

install_nwg_hello() {
  local s; s="$(src_path "nwg-hello")"
  [ -d "$s" ] || die "Missing source dir: $s"
  local d="/etc/nwg-hello"

  section "$BOX_GREEN" "nwg-hello -> /etc/nwg-hello"
  p "$BOX_GREEN" "Overwrite: $d"
  copy_dir_overwrite_to "$s" "$d"

  if is_root; then
    chown -R root:root -- "$d"
    chmod -R 755 -- "$d"
  else
    sudo chown -R root:root -- "$d"
    sudo chmod -R 755 -- "$d"
  fi

  p "$UI_OK" "Installed nwg-hello"
}

install_adw_gtk3() {
  local s; s="$(src_path "adw-gtk3v5.6.tar.xz")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="/usr/share/themes"

  section "$BOX_PURPLE" "adw-gtk3v5.6.tar.xz -> /usr/share/themes"
  p "$BOX_PURPLE" "Extract to: $d"
  extract_tar_xz_overwrite "$s" "$d"
  p "$UI_OK" "Installed adw-gtk3"
}

install_catppuccin_cursors() {
  local s; s="$(src_path "catppuccin-mocha-dark-cursors.zip")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="/usr/share/icons"

  section "$BOX_PURPLE" "catppuccin-mocha-dark-cursors.zip -> /usr/share/icons"
  p "$BOX_PURPLE" "Extract to: $d"
  extract_zip_overwrite "$s" "$d"
  p "$UI_OK" "Installed catppuccin cursors"
}

install_all() {
  install_pictures
  install_bashrc
  install_vimrc
  install_pacman_conf
  install_cpupower
  install_greetd
  install_hypr
  install_mangohud
  install_nvim
  install_nwg_bar
  install_nwg_drawer
  install_nwg_hello
  install_nwg_panel
  install_adw_gtk3
  install_catppuccin_cursors
}

print_menu() {
  say ""
  cat_line "$UI_ML"
  p "$UI_ML" "Root: $HYPRDECK_DIR"
  p "$UI_ML" "User: $USERNAME ($USER_HOME)"
  cat_line "$UI_ML"

  p "$BOX_PURPLE" "pictures            -> ~/Pictures                      (Pictures/)"
  p "$BOX_YELLOW" "bashrc              -> ~/.bashrc                       (bashrc)"
  p "$BOX_YELLOW" "vimrc               -> ~/.vimrc                        (vimrc)"
  p "$BOX_RED"    "pacman              -> /etc/pacman.conf                (pacman.conf)"
  p "$BOX_BLUE"   "cpupower            -> /etc/default/cpupower           (cpupower)"

  p "$BOX_GREEN"  "greetd              -> /etc/greetd                     (greetd/)"
  p "$BOX_BLUE"   "hypr                -> ~/.config/hypr                  (hypr/)"
  p "$BOX_BLUE"   "MangoHud            -> ~/.config/MangoHud              (MangoHud/)"
  p "$BOX_GREEN"  "nvim                -> ~/.config/nvim                  (nvim/)"
  p "$BOX_GREEN"  "nwg-bar             -> ~/.config/nwg-bar               (nwg-bar/)"
  p "$BOX_GREEN"  "nwg-drawer          -> ~/.config/nwg-drawer            (nwg-drawer/)"
  p "$BOX_GREEN"  "nwg-hello           -> /etc/nwg-hello                  (nwg-hello/)"
  p "$BOX_GREEN"  "nwg-panel           -> ~/.config/nwg-panel             (nwg-panel/)"

  p "$BOX_PURPLE" "adw-gtk3 theme       -> /usr/share/themes               (adw-gtk3v5.6.tar.xz)"
  p "$BOX_PURPLE" "catppuccin cursors   -> /usr/share/icons                (catppuccin-mocha-dark-cursors.zip)"
  say ""
  p "$UI_NOTE" "Type: all  or list items (e.g. 'hypr nvim')"
}

run_choice() {
  case "${1,,}" in
    pictures|pics) install_pictures ;;
    bashrc|bash) install_bashrc ;;
    vimrc|vim) install_vimrc ;;
    pacman|pacman.conf) install_pacman_conf ;;
    cpupower) install_cpupower ;;

    greetd) install_greetd ;;
    hypr) install_hypr ;;
    mangohud|mango) install_mangohud ;;
    nvim|neovim) install_nvim ;;
    nwg-bar|bar) install_nwg_bar ;;
    nwg-drawer|drawer) install_nwg_drawer ;;
    nwg-hello|hello) install_nwg_hello ;;
    nwg-panel|panel) install_nwg_panel ;;

    adw-gtk3|adwgtk3|theme) install_adw_gtk3 ;;
    catppuccin|cursors|catppuccin-cursors) install_catppuccin_cursors ;;
    *) die "Invalid selection: $1" ;;
  esac
}

main_loop() {
  header
  tutorial

  while true; do
    print_menu
    local sel=""
    prompt_read sel "> " ""
    maybe_quit "$sel"

    case "${sel,,}" in
      all)
        if confirm_yes_default "Install ALL items (overwrite everything listed)?"; then
          install_all
          p "$UI_OK" "Done."
          goodbye "HyprDeck install complete - MarleyLinux"
        else
          p "$UI_NOTE" "Cancelled."
        fi
        ;;
      *)
        sel="${sel//,/ }"
        for tok in $sel; do
          run_choice "$tok"
        done
        p "$UI_OK" "Selection complete."
        ;;
    esac
  done
}

main_loop

