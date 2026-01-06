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
  local __varname="$1"
  local __prompt="$2"
  local __default="${3-}"
  local __val=""

  if [ -t 0 ]; then
    read -r -p "$__prompt" __val || true
  elif [ -r /dev/tty ]; then
    read -r -p "$__prompt" __val < /dev/tty || true
  else
    __val=""
  fi

  maybe_quit "$__val"
  if [ -z "$__val" ] && [ -n "$__default" ]; then __val="$__default"; fi
  printf -v "$__varname" '%s' "$__val"
}

# Enter counts as YES.
confirm_yes_default() {
  local yn=""
  prompt_read yn "$1 [Y/n] (or 'q'): " ""
  case "${yn,,}" in
    ""|y|yes) return 0 ;;
    n|no) return 1 ;;
    *) return 1 ;;
  esac
}

# ---------- UI (emoji -> ANSI boxes -> ASCII) ----------
has_noto_emoji() {
  command -v pacman >/dev/null 2>&1 || return 1
  pacman -Q noto-fonts-emoji >/dev/null 2>&1
}

supports_unicode() {
  case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf8*) return 0 ;;
    *) return 1 ;;
  esac
}

supports_ansi() {
  [ -t 1 ] || return 1
  [ "${NO_COLOR:-0}" = "1" ] && return 1
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
  if [ "${NO_EMOJI:-0}" = "1" ]; then
    USE_EMOJI=0
  elif [ "${FORCE_EMOJI:-0}" = "1" ]; then
    USE_EMOJI=1
  elif [ ! -t 1 ]; then
    USE_EMOJI=0
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

trap 'goodbye "Interrupted (Ctrl+C) - MarleyLinux"' INT

section() {
  local box="$1"
  local title="$2"
  say ""
  cat_line "$box"
  p "$box" "$title"
  cat_line "$box"
}

header() {
  say ""
  cat_line "$UI_ML"
  p "$UI_ML" "HyprDeck Installer - MarleyLinux"
  cat_line "$UI_ML"
}

tutorial() {
  section "$UI_ML" "Tutorial: HyprDeck dotfiles (Steam Deck vibe on Arch + Hyprland)"

  p "$UI_NOTE" "What this is:"
  p "$UI_NOTE" "  HyprDeck installs dotfiles for a Steam Deck-style setup on regular Arch using Hyprland."
  say ""

  p "$UI_NOTE" "How to use:"
  p "$UI_NOTE" "  1) Put the HyprDeck files/folders next to this script (or inside ./hyprdeck/)."
  p "$UI_NOTE" "  2) chmod +x ./hyprdeck.sh"
  p "$UI_NOTE" "  3) ./hyprdeck.sh"
  say ""

  p "$UI_NOTE" "Selecting installs:"
  p "$UI_NOTE" "  • Type one or more names (space-separated), or type: all"
  p "$UI_NOTE" "  • Type: q  to quit"
  say ""

  p "$UI_ERR"  "WARNING:"
  p "$UI_ERR"  "  This script OVERWRITES targets (no backups)."
  p "$UI_NOTE" "  System paths (/etc, /usr) require sudo."
  say ""

  local tmp=""
  prompt_read tmp "Press Enter to continue (or 'q'): " ""
}

# ---------- Current user (no prompt) ----------
if is_root && [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER:-}" != "root" ]; then
  USERNAME="$SUDO_USER"
else
  USERNAME="$(id -un)"
fi

USER_HOME="$(getent passwd "$USERNAME" | awk -F: '{print $6}')"
[ -n "${USER_HOME:-}" ] || die "Could not resolve home for user: $USERNAME"

USER_CONFIG_DIR="$USER_HOME/.config"

# ---------- HyprDeck root auto-detect ----------
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

  if [ -d "$flat/hypr" ] || [ -d "$flat/nwg-panel" ] || [ -d "$flat/Pictures" ] || [ -f "$flat/bashrc" ] || [ -f "$flat/pacman.conf" ]; then
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

# ---------- Overwrite ops (NO BACKUPS) ----------
needs_root_for_path() {
  case "$1" in
    /etc/*|/usr/*) return 0 ;;
    *) return 1 ;;
  esac
}

run_for_path() {
  local path="$1"; shift
  if is_root; then
    "$@"
  else
    if needs_root_for_path "$path"; then
      sudo "$@"
    else
      "$@"
    fi
  fi
}

ensure_dir_for_path() {
  local dir="$1"
  run_for_path "$dir" install -d -m 0755 "$dir"
}

rm_force_for_path() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    run_for_path "$path" rm -rf -- "$path"
  fi
}

copy_file_overwrite_to() {
  local src="$1"
  local dest="$2"
  [ -f "$src" ] || die "Missing source file: $src"
  rm_force_for_path "$dest"
  ensure_dir_for_path "$(dirname "$dest")"
  run_for_path "$dest" install -m 0644 "$src" "$dest"
}

copy_dir_overwrite_to() {
  local src="$1"
  local dest="$2" # full destination dir path
  [ -d "$src" ] || die "Missing source dir: $src"

  if [ "$(basename "$src")" != "$(basename "$dest")" ]; then
    die "Internal error: basename mismatch: src=$(basename "$src") dest=$(basename "$dest")"
  fi

  rm_force_for_path "$dest"
  ensure_dir_for_path "$(dirname "$dest")"

  if command -v rsync >/dev/null 2>&1; then
    run_for_path "$dest" rsync -a "$src" "$(dirname "$dest")/"
  else
    run_for_path "$dest" cp -a "$src" "$(dirname "$dest")/"
  fi
}

fix_user_ownership_under_home() {
  local path="$1"
  if is_root; then
    case "$path" in
      "$USER_HOME"/*) chown -R "$USERNAME:$USERNAME" "$path" ;;
    esac
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"
}

list_toplevel_from_tar() {
  local archive="$1"
  tar -tf "$archive" | awk -F/ 'NF{print $1}' | sort -u
}

list_toplevel_from_zip() {
  local archive="$1"
  if command -v unzip >/dev/null 2>&1; then
    unzip -Z1 "$archive" | awk -F/ 'NF{print $1}' | sort -u
  else
    require_cmd bsdtar
    bsdtar -tf "$archive" | awk -F/ 'NF{print $1}' | sort -u
  fi
}

extract_tar_xz_overwrite() {
  local archive="$1"
  local dest="$2"
  [ -f "$archive" ] || die "Missing source file: $archive"
  require_cmd tar

  ensure_dir_for_path "$dest"

  local top
  while IFS= read -r top; do
    [ -n "$top" ] || continue
    rm_force_for_path "$dest/$top"
  done < <(list_toplevel_from_tar "$archive")

  run_for_path "$dest" tar -xJf "$archive" -C "$dest"
}

extract_zip_overwrite() {
  local archive="$1"
  local dest="$2"
  [ -f "$archive" ] || die "Missing source file: $archive"

  ensure_dir_for_path "$dest"

  local top
  while IFS= read -r top; do
    [ -n "$top" ] || continue
    rm_force_for_path "$dest/$top"
  done < <(list_toplevel_from_zip "$archive")

  if command -v unzip >/dev/null 2>&1; then
    run_for_path "$dest" unzip -oq "$archive" -d "$dest"
  else
    require_cmd bsdtar
    run_for_path "$dest" bsdtar -xf "$archive" -C "$dest"
  fi
}

# ---------- Installers ----------
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
  p "$UI_OK" "Installed .bashrc"
}

install_vimrc() {
  local s; s="$(src_path "vimrc")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="$USER_HOME/.vimrc"

  section "$BOX_YELLOW" "vimrc -> ~/.vimrc"
  p "$BOX_YELLOW" "Overwrite: $d"
  copy_file_overwrite_to "$s" "$d"
  fix_user_ownership_under_home "$d"
  p "$UI_OK" "Installed .vimrc"
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

install_greetd()     { install_config_dir "greetd"     "$BOX_GREEN"; }
install_hypr()       { install_config_dir "hypr"       "$BOX_BLUE"; }
install_mangohud()   { install_config_dir "MangoHud"   "$BOX_BLUE"; }
install_nvim()       { install_config_dir "nvim"       "$BOX_GREEN"; }
install_nwg_bar()    { install_config_dir "nwg-bar"    "$BOX_GREEN"; }
install_nwg_drawer() { install_config_dir "nwg-drawer" "$BOX_GREEN"; }
install_nwg_panel()  { install_config_dir "nwg-panel"  "$BOX_GREEN"; }

# ---- CHANGED: nwg-hello now installs system-wide into /etc/nwg-hello ----
install_nwg_hello() {
  local s; s="$(src_path "nwg-hello")"
  [ -d "$s" ] || die "Missing source dir: $s"
  local d="/etc/nwg-hello"

  section "$BOX_GREEN" "nwg-hello -> /etc/nwg-hello"
  p "$BOX_GREEN" "Overwrite: $d"
  copy_dir_overwrite_to "$s" "$d"

  # Keep it clean/consistent for system config
  run_for_path "$d" chown -R root:root "$d"
  run_for_path "$d" chmod -R 755 "$d"

  p "$UI_OK" "Installed nwg-hello (system-wide)"
}

install_adw_gtk3() {
  local s; s="$(src_path "adw-gtk3v5.6.tar.xz")"
  [ -f "$s" ] || die "Missing source file: $s"
  local d="/usr/share/themes"

  section "$BOX_PURPLE" "adw-gtk3v5.6.tar.xz -> /usr/share/themes"
  p "$BOX_PURPLE" "Extract to: $d"
  extract_tar_xz_overwrite "$s" "$d"
  p "$UI_OK" "Installed adw-gtk3 theme"
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

  p "$BOX_GREEN"  "greetd              -> ~/.config/greetd                (greetd/)"
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
  p "$UI_NOTE" "Type: names (space-separated), or: all, or: q"
}

run_choice() {
  local tok="${1,,}"
  case "$tok" in
    pictures|pics) install_pictures ;;
    bashrc|bash) install_bashrc ;;
    vimrc|vim) install_vimrc ;;
    pacman|pacman.conf|pacmanconf) install_pacman_conf ;;
    cpupower|cpu) install_cpupower ;;

    greetd) install_greetd ;;
    hypr|hyprland) install_hypr ;;
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

  while :; do
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
        p "$UI_OK" "Done."
        goodbye "HyprDeck install complete - MarleyLinux"
        ;;
    esac
  done
}

main_loop
