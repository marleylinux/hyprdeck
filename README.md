# HyprDeck (MarleyLinux)

HyprDeck is a small dotfiles installer for a **Steam Deck desktop setup on Arch Linux using Hyprland**.

It installs config folders into `~/.config`, dotfiles into your home directory, and system files into `/etc` + `/usr/share` (themes/icons).  
**It overwrites targets (no backups).**

---

## What it installs

### Home
- `Pictures/` → `~/Pictures`
- `bashrc` → `~/.bashrc`
- `vimrc` → `~/.vimrc`
- 
### `~/.config`
- `greetd/`
- `hypr/`
- `MangoHud/`
- `nvim/`
- `nwg-bar/`
- `nwg-drawer/`
- `nwg-panel/`

### System
- `pacman.conf` → `/etc/pacman.conf`
- `cpupower` → `/etc/default/cpupower`
- `adw-gtk3v5.6.tar.xz` → extracted to `/usr/share/themes`
- `catppuccin-mocha-dark-cursors.zip` → extracted to `/usr/share/icons`
- - `nwg-hello/` → extracted to `/etc/nwg-hello`

---

## Repo layout

Put everything next to `hyprdeck.sh`:

DOES NOT INCLUDE ON SCREEN KEYBOARD OR STEAM DECK TRACKPAD SUPPORT (WORKS IN GAME JUST NOT ON DESKTOP)
