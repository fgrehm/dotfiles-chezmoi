# chezmakase

An Omakase-style Developer Setup for Ubuntu 24.04+ powered by Chezmoi

## Overview

`chezmakase` is [@fgrehm][gh-fgrehm]'s take to turn a fresh Ubuntu installation into a
fully-configured, beautiful, and modern web development system by running a single command.

It standardizes development environment setups across machines / containers and is inspired by
[Omakub][omakub], being the main difference that it is powered by [Chezmoi][chezmoi].

> **NOTE:** At first this is tailored to [@fgrehm][gh-fgrehm]'s laptops running Ubuntu 24.04 and
> his Devcontainers environments, extension to other OSes and workflows are welcome!

## Features

- **Automated dotfiles & config management** via Chezmoi
- **Devcontainer support** for consistent containerized development environments
- **Optional components** - Choose which tools to install with curated setup profiles
- **Container-aware** - Automatically adapts behavior for devcontainer vs bare metal
- **Idempotent scripts** to safely re-run without side-effects
- **Lightweight & fast**: minimal dependencies, no heavyweight frameworks
- **Extensible**: easily add new tools, scripts, and OS support
- **Reproducible**: guarantee same environment on any machine
- **Testing framework** - Docker-based validation system for reliable installations

## Quick Start

### Basic Setup (Recommended)

```bash
sh -c "$(wget -qO- get.chezmoi.io)" -- init --verbose --apply fgrehm/dotfiles-chezmoi
```

### Setup Types

During initialization, choose from curated profiles:

- **Basic**: Recommended defaults (Cursor, Neovim, Brave, development tools)
- **Minimal**: Lightweight for containers (Neovim, CLI tools only)
- **Developer**: Full environment (all editors, services, development tools)
- **Custom**: Interactive selection of each component

### Component Categories

chezmakase organizes tools into logical categories:

- **Editors**: Cursor IDE, Neovim, VS Code
- **Browsers**: Brave Browser
- **Development**: Docker, Node.js, Claude CLI, shellcheck, markdown linting
- **Services**: Ollama (LLM), Open WebUI, PhotoPrism (self-hosted via Docker)
- **Desktop**: Notion, WhatsApp (as web apps)
- **System**: Fonts, Zsh configuration, GNOME settings
- **Security**: 1Password, SSH configuration

## How It Works

1. **Chezmoi** manages your dotfiles and templates in a single repo
2. **Setup profiles** provide curated defaults for different use cases
3. **Environment detection** automatically adapts for containers vs bare metal
4. **Conditional installation** only installs selected components
5. **Modular scripts** handle package installation and configuration

## Container Support

chezmakase automatically detects devcontainer environments and:

- Skips GUI applications and desktop integrations
- Disables system-level configurations incompatible with containers
- Maintains full development tool functionality
- Uses host Docker instead of installing Docker inside containers

## Testing

A Docker-based testing framework validates installations:

```bash
# Test container detection and configuration
./test/simulate-devcontainer.sh detection

# Test all functionality
./test/simulate-devcontainer.sh test

# Interactive container shell for debugging
./test/simulate-devcontainer.sh interactive
```

## Comparison to Other Tools

| Feature                          | chezmakase                | Omakub                          | Chezmoi                |
| -------------------------------- | ------------------------- | ------------------------------- | ---------------------- |
| Dotfile management               | ✅ via Chezmoi            | ❌                              | ✅                     |
| Container support                | ✅ Devcontainers-ready    | ❌                              | ✅ (DIY)               |
| Guided "[omakase][wiki-omakase]" | ✅ curated defaults       | ✅ curated OS defaults          | ❌ (user-defined)      |
| Extensibility                    | ✅ easy to fork & extend  | limited community contributions | ✅ plugins & templates |
| Optional components              | ✅ choose what to install | ❌ all-or-nothing               | ❌ (user-defined)      |

- **Why not just Omakub?** Omakub focuses on a curated, opinionated set of tools for Ubuntu.
  While `chezmakase` is Ubuntu-focused, it can be extended to other OSes by leveraging Chezmoi
  and provides flexible component selection.
- **Why not just Chezmoi?** Chezmoi handles dotfiles but doesn't provide curated defaults or
  guided setup experiences.

## Development

### Documentation

- `docs/configuration-schema.md` - Complete component configuration reference
- `.agent-os/product/chezmoi-best-practices.md` - Development patterns and practices
- `.agent-os/product/markdown-standards.md` - Documentation standards

### Testing Framework

The testing system uses Docker containers to validate installations:

- **Fast iterations** with image and container caching
- **Environment simulation** for both devcontainer and bare metal scenarios
- **Automated validation** of configuration templates and component behavior

## Customization

> **TODO**: Document user customization strategy - how users should fork, extend, and maintain
> their own configurations while staying compatible with upstream chezmakase improvements.

## License

This project is licensed under the MIT License.

## Credits

- [@danteregis][gh-danteregis] for introducing Chezmoi to @fgrehm and blowing his mind by showing
  [this video][chezmoi-video] by [@logandonley][gh-logandonley]
- [@dhh][gh-dhh]'s [Omakub][omakub] as a big source of inspiration and some code for this
  project's scripts
- [Tom Payne](https://github.com/twpayne) for creating Chezmoi
- And [everyone else that tagged their repo as `chezmoi` in GitHub][gh-chezmoi-topics]

[gh-fgrehm]: https://github.com/fgrehm
[omakub]: https://omakub.org
[chezmoi]: https://www.chezmoi.io/
[wiki-omakase]: https://en.wikipedia.org/wiki/Omakase
[chezmoi-video]: https://www.youtube.com/watch?v=-RkANM9FfTM
[gh-danteregis]: https://github.com/danteregis
[gh-logandonley]: https://github.com/logandonley
[gh-dhh]: https://github.com/dhh
[gh-chezmoi-topics]: https://github.com/topics/chezmoi?o=desc&s=stars
