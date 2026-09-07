# macOS terminal template

A repeatable starting point for a clean macOS terminal. The installer sets up Ghostty, Oh My Posh, MesloLGM Nerd Font, zsh autosuggestions, and zsh syntax highlighting without replacing the rest of your shell configuration.

## Quick start

Run this on a Mac with an internet connection:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/adminsdhb/macOS-terminal-template/main/bootstrap.sh)"
```

The installer:

- Installs Homebrew if it is missing.
- Installs the packages in `Brewfile`.
- Copies the included Oh My Posh theme and Ghostty settings.
- Adds one guarded source block to `~/.zshrc`.
- Backs up existing files before changing them.

Backups are stored under `~/.terminal-template-backups/` with a timestamp. Existing machine-specific setup such as `nvm`, `pyenv`, Android SDK variables, and Java settings is left alone.

## Local checkout

To inspect or customize the files before installing:

```sh
git clone https://github.com/adminsdhb/macOS-terminal-template.git
cd macOS-terminal-template
bash bootstrap.sh
```

## Customize

- Edit `themes/catppuccin.omp.json` to change the prompt.
- Edit `ghostty/config` to change the terminal window.
- Edit `zshrc.d/terminal-template.zsh` to change shell behavior.
- Re-run `bash bootstrap.sh` after making changes; the installer creates a fresh backup first.

The template targets macOS and assumes zsh, Homebrew, and a normal interactive shell session. It does not install development toolchains such as Xcode, Android Studio, Node, Python, or Rust.

## Agent orchestration

The template includes `bin/run-agent`, a small shared entry point for handing the same task format to different agent CLIs. The bootstrap copies it into `~/.config/macOS-terminal-template/bin` and adds that directory to your shell PATH.

```sh
./bin/run-agent codex "Review the current branch and summarize risks."
./bin/run-agent claude "Update the README and run the tests."
RUN_AGENT_LOG_FILE=tasks/logs/review.log \
  ./bin/run-agent copilot "Inspect the authentication flow."
```

Supported tools are `claude`, `codex`, `copilot`, `gemini`, and `aider`. Agent CLIs remain optional: the wrapper prints an install hint and exits cleanly when one is not installed. The bootstrap installs the shared terminal tools only when Homebrew reports they are missing. Use `tasks/README.md` for the input, output, and logging handoff format.
