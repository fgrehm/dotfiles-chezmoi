# Technical Stack

> Last Updated: 2025-08-08
> Version: 1.0.0

## Configuration Management

- **Framework:** chezmoi
- **Version:** Latest stable
- **Purpose:** Cross-platform dotfiles management with templating

## Shell Environment

- **Primary Shells:** Bash, Zsh
- **Shell Framework:** Custom modular system
- **Configuration:** Template-driven with conditional logic

## Package Management

- **Linux:** Native package managers (apt, yum, pacman, etc.)
- **Future Platforms:** macOS support (Homebrew) - deferred
- **Container Detection:** Automatic adaptation for containerized environments

## Development Tools

- **Primary Editor:** Neovim with LazyVim
- **Additional Editors:** Cursor IDE, VS Code
- **Version Control:** Git with templated configurations
- **Container Platform:** Docker with Docker Compose

## System Integration

- **Desktop Environment:** GNOME (dconf settings management)
- **Font Management:** System-specific font installation
- **Application Creation:** Custom desktop entries for web applications

## Installation Architecture

- **Phase System:** Multi-stage installation process
  - Phase 0: Bootstrap (system packages and updates)
  - Phase 1: Installers (application-specific installations)
  - Phase 2: Configurations (system and application setup)
- **Error Handling:** Robust error handling with `set -eo pipefail`
- **Idempotency:** `run_once_` and `run_onchange_` script prefixes

## Self-Hosted Services

- **AI/ML Platform:** Ollama with OpenWebUI frontend
- **Media Management:** PhotoPrism
- **Service Management:** Docker Compose based

## Cross-Platform Compatibility

- **Templating Engine:** Go templates with chezmoi variables
- **System Detection:** Automatic platform and distribution detection
- **Conditional Execution:** Platform-specific logic in templates
- **Variable Access:** `{{ .chezmoi.username }}`, `{{ .chezmoi.workingTree }}`, `{{ .virt.container }}`

## Development Utilities

- **Configuration Comparison:** dconf-diff.sh for system state tracking
- **Symlink Management:** Strategic symlinking from configs/ directory
- **Template Processing:** Dynamic configuration generation based on system state
