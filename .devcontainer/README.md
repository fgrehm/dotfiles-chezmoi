# Chezmakase Development Container

This devcontainer provides a complete development environment for working on the chezmakase
dotfiles system. It's designed for collaborative development and testing of chezmoi
configurations.

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/fgrehm/dotfiles-chezmoi.git
   cd dotfiles-chezmoi
   ```

2. **Open in VS Code:**

   ```bash
   code .
   ```

3. **Reopen in Container:**
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
   - Type "Dev Containers: Reopen in Container"
   - Wait for the container to build and setup to complete

## What's Included

### Development Tools

- **chezmoi** - The dotfiles manager
- **shellcheck** - Shell script linting
- **markdownlint-cli2** - Markdown linting (respects .markdownlint.json)
- **Docker** - For testing docker-compose services
- **Node.js LTS** - For JavaScript-based tools
- **Git** - Latest version with sensible defaults

### Editor Extensions

- Markdown linting with proper line length rules (100 chars)
- Shell script validation with shellcheck
- Docker support
- JSON/YAML editing support
- GitHub Copilot (if configured)

### Container Detection

The devcontainer automatically:

- Creates `/var/devcontainer/.devcontainer` marker for chezmoi detection
- Configures environment variables for container mode
- Skips installation of desktop applications and GUI tools
- Provides Docker-outside-of-Docker for testing services

## Testing Chezmakase

### Test Installation Process

```bash
# Initialize with the actual repository (tests real installation)
chezmoi init --verbose fgrehm/dotfiles-chezmoi

# Preview what would be installed (dry run)
chezmoi diff

# Apply the configuration (actual installation)
chezmoi apply

# Check if everything is working
chezmoi doctor
```

### Test Container-Specific Behavior

The system should automatically:

- Skip GUI applications (Brave, desktop files, etc.)
- Skip system-level configurations (dconf, etc.)
- Install only containerized development tools
- Properly handle Docker services via docker-compose

### Linting and Validation

```bash
# Check markdown files
markdownlint-cli2 '**/*.md'

# Check shell scripts
shellcheck home/.chezmoiscripts/**/*.sh

# Validate chezmoi templates
chezmoi execute-template < home/.chezmoi.toml.tmpl
```

## Development Workflow

### Making Changes

1. Edit configuration files in the repository
2. Test changes with `chezmoi diff`
3. Apply with `chezmoi apply` or `chezmoi apply --force`
4. Validate with linting tools
5. Commit and push changes

### Testing Different Scenarios

```bash
# Test as if in a fresh devcontainer
rm -rf ~/.local/share/chezmoi && chezmoi init --verbose fgrehm/dotfiles-chezmoi

# Test specific components
chezmoi apply --include files
chezmoi apply --include scripts
```

## Troubleshooting

### Common Issues

1. **Permission errors:** The container runs as `vscode` user with sudo access
2. **Docker not working:** Ensure Docker is running on the host system
3. **chezmoi not found:** Restart the terminal or source ~/.bashrc

### Reset Environment

```bash
# Complete reset
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi
chezmoi init --verbose fgrehm/dotfiles-chezmoi
```

### Debug Mode

```bash
# Run chezmoi with verbose output
chezmoi --verbose apply

# Check template execution
chezmoi execute-template --init < home/.chezmoi.toml.tmpl
```

## Contributing

1. Make your changes in the repository
2. Test them in the devcontainer environment
3. Ensure all linting passes
4. Submit a pull request

The devcontainer ensures a consistent development environment for all contributors.
