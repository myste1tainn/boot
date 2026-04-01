# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal **macOS bootstrapping and configuration repository** containing dotfiles, configuration files, and setup scripts for a complete development environment. It is not a software project with build/test cycles—it's a collection of configurations and installation/management scripts.

### Key Directories

- **`zsh/`** — Shell configuration including `.zshrc` and oh-my-zsh setup
- **`git/`** — Git configuration (`gitconfig`) and batch git management scripts (clone, push, pull, merge, status across multiple repos)
- **`nvim/`** — Neovim configuration (Lua-based with LSP setup)
- **`vim/`** — Vim configuration
- **`tmux/`** — Tmux configuration
- **`kitty/`** — Kitty terminal emulator configuration
- **`aerospace/`, `hammperspoon/`** — macOS window management and automation
- **`macos/`** — macOS system settings and preferences
- **`gitlab/`** — GitLab-specific configurations
- **`icons/`** — Icon assets
- **`keys & licenses/`** — License and key storage (private)

## Common Operations

### Installation & Setup

- **`install-tools.sh`** — Installs common CLI tools via Homebrew (htop, git, jq, yq, maven, podman, minikube, python, etc.)
- **`install-apps.sh`** — Installs macOS applications via DMG files and Homebrew casks (Alfred, Brave, Typora, WezTerm, etc.)
- **`dmg-installer.sh`** — Helper script for downloading and installing DMG packages

Each tool subdirectory (zsh, nvim, git, etc.) typically has:
- `install.sh` — Sets up links or installs configuration
- `linkfiles.sh` — Links config files to `~`
- `.sh` scripts — Utility and setup scripts

### Git Utility Scripts

The `git/` directory contains batch scripts for managing multiple repositories:

- **`all-status.sh`** — Shows status of all git repos in a directory
- **`all-pull.sh`** — Pulls updates from all repos
- **`all-push.sh`** — Pushes commits from all repos
- **`all-checkout.sh`** — Checks out a branch across all repos
- **`all-merge.sh`** — Merges branches across all repos
- **`all-commit-push.sh`** — Commits and pushes across all repos
- **`bump-tag.sh`** / **`all-bump-tag.sh`** — Creates version tags
- **`clone-group.sh`** — Clones a group of related repositories
- **`gitlab-create-mr.sh`** / **`create-mr.sh`** — Creates merge requests
- **`mass-git-configure.sh`** — Configures git across multiple repos
- **`contributors.sh`** / **`contributors-loc.sh`** — Analyzes repository statistics

**Usage pattern**: Most scripts accept a directory/repo name as the first argument and execute the operation across that path or a group of repos.

## Architecture Notes

### Git Configuration (`git/gitconfig`)

Likely contains:
- User identity and credentials
- Default push/pull behavior
- Aliases for common commands
- URL rewriting for GitLab/GitHub

### Shell Configuration (`zsh/.zshrc`)

Loads oh-my-zsh plugins and custom aliases. Typically sources:
- Oh-my-zsh framework configuration
- Custom environment variables
- Aliases for common git and development commands

### Neovim Setup (`nvim/`)

- **Lua-based configuration** (`lua/` directory)
- **LSP installations** tracked in `lsp_installations.txt`
- **Symlinked config structure** with `home/` containing the actual config files that get linked to `~/.config/nvim`
- **Filetype plugins** in `ftplugin/`
- **Post-load scripts** in `after/`

## Modifying Configurations

When updating tool configurations:

1. **Edit directly** in the subdirectory (e.g., edit `nvim/lua/init.lua` directly)
2. **Run install scripts** if changes need to be applied to the system (run `<tool>/install.sh`)
3. **Symlink/link files** using the `linkfiles.sh` scripts to connect config to home directory

## Important Notes

- This is a **personal configuration repository**, not a collaborative project
- Changes here affect the user's development environment directly
- Some directories (like `keys & licenses`) contain sensitive information and should not be modified carelessly
- Installation scripts use Homebrew and assume macOS environment
