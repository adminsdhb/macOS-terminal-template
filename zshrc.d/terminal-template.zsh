if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
  fi
fi

if command -v brew >/dev/null 2>&1; then
  autosuggestions_file="$(brew --prefix zsh-autosuggestions 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  syntax_highlighting_file="$(brew --prefix zsh-syntax-highlighting 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  [[ -r "$autosuggestions_file" ]] && source "$autosuggestions_file"
  [[ -r "$syntax_highlighting_file" ]] && source "$syntax_highlighting_file"
fi

export POSH_THEME="$HOME/.config/macOS-terminal-template/catppuccin.omp.json"
if command -v oh-my-posh >/dev/null 2>&1 && [[ -r "$POSH_THEME" ]]; then
  eval "$(oh-my-posh init zsh --config "$POSH_THEME")"
fi
