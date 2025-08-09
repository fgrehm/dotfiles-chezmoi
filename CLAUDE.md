# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-managed dotfiles repository that manages system configuration, application
installations, and development environment setup across Linux systems. The repository uses
chemzoi's templating system to conditionally apply configurations based on system characteristics.

## Key Commands

### Chezmoi Operations

```bash
# Initialize and apply dotfiles
sh -c "$(wget -qO- get.chezmoi.io)" -- init --verbose --apply fgrehm/dotfiles-chezmoi

# Apply changes after modification
chezmoi apply

# Edit a managed file
chezmoi edit <file>

# See what changes would be applied
chezmoi diff

# Add a new file to be managed
chezmoi add <file>
```

### Development Utilities

```bash
# Compare dconf settings (shows system configuration changes)
./utils/dconf-diff.sh
```

## Architecture and Structure

### Core Organization

- `home/` - Contains all dotfiles and configurations that will be symlinked/copied to the
  user's home directory
- `configs/` - Application-specific configurations (nvim, cursor, vscode)
- `home/.chezmoiscripts/` - Installation and configuration scripts organized in phases:
  - `00-bootstrap/` - System package installation and updates
  - `01-installers/` - Application-specific installers (docker, cursor, brave, etc.)
  - `02-configurations/` - System and application configuration scripts

### Key Components

#### Chezmoi Templates

- Files ending in `.tmpl` are chezmoi templates that support Go templating
- Conditional execution based on system characteristics (e.g., `{{ if .virt.container }}`)
- Access to chezmoi variables like `{{ .chezmoi.username }}` and `{{ .chezmoi.workingTree }}`

#### Shell Environment

- `home/dot_bashrc` and `home/dot_zshrc` - Shell configurations
- `home/dot_shell.d/` - Modular shell scripts loaded by shell configs
- `home/dot_exports` and `home/dot_aliases` - Environment variables and command aliases

#### Application Configurations

- Editor configs symlinked from `configs/` to avoid duplication
- Desktop applications created programmatically (notion.desktop, whatsapp.desktop)
- Docker compose files for self-hosted services (ollama, openwebui, photoprism)

#### Installation Scripts

- Scripts use `run_once_` prefix for one-time installation
- Scripts use `run_onchange_` prefix to re-run when content changes
- Template files (`.tmpl`) allow conditional execution based on system state
- Installation scripts handle dependencies and system-specific requirements

### Development Environment

- Neovim configuration based on LazyVim framework in `configs/nvim/`
- Cursor IDE setup with custom keybindings and settings
- VS Code configuration with synchronized settings
- Git configuration with templated user settings

### System Integration

- dconf settings management for GNOME desktop environment  
- Custom desktop entries for web applications
- Font installation and system package management
- Docker-based service definitions for development tools

## Important Notes

- The repository structure follows chezmoi conventions where `dot_` prefixes become `.` in the
  target system
- Scripts are executed in numerical/alphabetical order by phase
- Template files support conditional logic based on system detection
- All installation scripts include error handling with `set -eo pipefail`
- Container environments are detected and skip certain installations automatically

## Documentation Standards

- **Markdown Line Length**: Maximum 100 characters per line (configured in `.markdownlint.json`)
- **File Endings**: All markdown files must end with exactly one newline character (MD047)
- When writing markdown files, wrap lines at 100 characters for better readability and linting compliance

## Git Commit Guidelines

- All commits made by Claude Code should end with: `🤖 Generated with Claude Code`
- NEVER include "Co-Authored-By: Claude <noreply@anthropic.com>" in commit messages

## Current Session Progress (2025-08-09)

### Completed Tasks

- ✅ Implemented comprehensive BATS testing framework with core, templates, installers, configs
- ✅ Added GitHub Actions CI/CD pipeline with integration tests
- ✅ Fixed all template execution issues (removed interactive prompts for CI)
- ✅ Fixed playground Docker build (shellcheck from GitHub releases, not pip)
- ✅ All local tests passing - ready to push branch `chezmakase-improvements`
- ✅ Updated documentation to reflect non-interactive initialization
- ✅ Added setupType to generated TOML for better debugging

### Key Files Modified

- `home/.chezmoi.toml.tmpl` - Removed promptChoiceOnce functions for CI compatibility, added
  setupType to output
- `test/chezmoi-playground.sh` - Fixed shellcheck installation method  
- `.github/workflows/test.yml` - Added proper chezmoi data configuration
- `README.md` - Updated setup instructions to show `--data setupType=<type>` syntax
- `docs/configuration-schema.md` - Updated roadmap to reflect completed setup profiles
- Complete BATS testing infrastructure in `test/` directory

### Recent Documentation Updates (Latest)

- Fixed outdated README that mentioned interactive prompts during initialization
- Updated setup instructions to show correct `--data setupType=<type>` usage
- Added `[data.setup] type = "setupType"` to generated TOML for transparency
- Users can now clearly see which profile was used via `chezmoi data`

### Next Steps After Push

- Complete Task 2.2: Optional components system (80% done)
- Add Task 3.3: markdownlint-cli2 to development tools
- Complete Task 4.3: Create bare metal test script (VirtualBox-based)
