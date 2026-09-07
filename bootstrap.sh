#!/usr/bin/env bash
set -euo pipefail

readonly repository_slug="${TERMINAL_TEMPLATE_REPO:-adminsdhb/macOS-terminal-template}"
readonly repository_ref="${TERMINAL_TEMPLATE_REF:-main}"
readonly install_dir="${TERMINAL_TEMPLATE_CONFIG_DIR:-$HOME/.config/macOS-terminal-template}"
readonly ghostty_config="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
readonly zshrc="$HOME/.zshrc"

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf '%s\n' 'This template supports macOS only.' >&2
  exit 1
fi

script_root=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

temporary_root=""
cleanup() {
  if [[ -n "$temporary_root" && -d "$temporary_root" ]]; then
    rm -rf "$temporary_root"
  fi
}
trap cleanup EXIT

if [[ ! -f "$script_root/Brewfile" ]]; then
  command -v curl >/dev/null 2>&1 || {
    printf '%s\n' 'curl is required to download the template.' >&2
    exit 1
  }
  command -v tar >/dev/null 2>&1 || {
    printf '%s\n' 'tar is required to download the template.' >&2
    exit 1
  }

  temporary_root="$(mktemp -d)"
  curl -fsSL "https://github.com/${repository_slug}/archive/refs/heads/${repository_ref}.tar.gz" | tar -xz -C "$temporary_root"
  script_root="$(find "$temporary_root" -mindepth 1 -maxdepth 1 -type d -print -quit)"
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
  else
    printf '%s\n' 'Homebrew is not installed. Starting the official installer.'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
  fi
fi

command -v brew >/dev/null 2>&1 || {
  printf '%s\n' 'Homebrew is unavailable after installation.' >&2
  exit 1
}

brew bundle --file="$script_root/Brewfile"

backup_root="$HOME/.terminal-template-backups/$(date +%Y%m%d-%H%M%S)"
backup_if_present() {
  local source_path="$1"
  if [[ -e "$source_path" ]]; then
    mkdir -p "$backup_root"
    if [[ ! -e "$backup_root/$(basename "$source_path")" ]]; then
      cp -R "$source_path" "$backup_root/$(basename "$source_path")"
    fi
  fi
}

install_ghostty_config() {
  local source_path="$1"
  local target_path="$2"

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    if [[ -f "$target_path" ]] && cmp -s "$source_path" "$target_path"; then
      printf '%s\n' "Ghostty config already matches the template: $target_path"
    else
      printf '%s\n' "Skipped existing Ghostty config (customization preserved): $target_path"
    fi
    return
  fi

  mkdir -p "$(dirname "$target_path")"
  cp "$source_path" "$target_path"
  printf '%s\n' "Installed Ghostty config: $target_path"
}

backup_if_present "$install_dir"
mkdir -p "$install_dir"
cp "$script_root/themes/catppuccin.omp.json" "$install_dir/catppuccin.omp.json"
cp "$script_root/zshrc.d/terminal-template.zsh" "$install_dir/terminal-template.zsh"
mkdir -p "$install_dir/bin"
cp "$script_root/bin/run-agent" "$install_dir/bin/run-agent"
chmod 755 "$install_dir/bin/run-agent"

install_ghostty_config "$script_root/ghostty/config" "$ghostty_config"

if ! [[ -f "$zshrc" ]] || ! grep -Fq '# macOS-terminal-template:begin' "$zshrc"; then
  backup_if_present "$zshrc"
  {
    printf '\n%s\n' '# macOS-terminal-template:begin'
    printf '%s\n' "source \"$install_dir/terminal-template.zsh\""
    printf '%s\n' '# macOS-terminal-template:agent-path-begin'
    printf '%s\n' "export PATH=\"$install_dir/bin:\$PATH\""
    printf '%s\n' '# macOS-terminal-template:agent-path-end'
    printf '%s\n' '# macOS-terminal-template:end'
  } >> "$zshrc"
fi

if ! grep -Fq '# macOS-terminal-template:agent-path-begin' "$zshrc"; then
  backup_if_present "$zshrc"
  {
    printf '\n%s\n' '# macOS-terminal-template:agent-path-begin'
    printf '%s\n' "export PATH=\"$install_dir/bin:\$PATH\""
    printf '%s\n' '# macOS-terminal-template:agent-path-end'
  } >> "$zshrc"
fi

printf '%s\n' 'macOS terminal template installed.'
printf '%s\n' "Restart your terminal or run: source \"$zshrc\""
printf '%s\n' "Agent wrapper: $install_dir/bin/run-agent"
if [[ -d "$backup_root" ]]; then
  printf '%s\n' "Backups: $backup_root"
fi
