# Product Mission

> Last Updated: 2025-08-08
> Version: 1.0.0

## Pitch

Chezmakase is a customizable, chezmoi-powered dotfiles distribution that provides developers
with a complete development environment setup across Linux platforms. Unlike Ubuntu-specific
solutions like Omakub, Chezmakase leverages chezmoi's templating system to deliver
cross-distribution compatibility while maintaining the simplicity of a one-command installation.

## Users

**Primary Users:**
- Software developers working across different Linux distributions
- DevOps engineers managing multiple development machines
- Development teams seeking standardized environment setup
- Individual developers wanting a robust, extensible dotfiles solution

**User Personas:**
- **The Platform Jumper**: Developers who work across different operating systems and need
  consistent tooling
- **The Team Lead**: Engineering managers who want to onboard new developers quickly with
  standardized environments  
- **The Minimalist**: Developers who want a clean, organized system without bloat
- **The Customizer**: Power users who need a flexible foundation they can extend

## The Problem

Current dotfiles solutions are either too platform-specific (like Omakub for Ubuntu) or too
complex to set up and maintain. Developers face several pain points:

1. **Platform Lock-in**: Existing solutions work well on one platform but fail on others
2. **Setup Complexity**: Manual configuration of development environments is time-consuming
   and error-prone
3. **Maintenance Burden**: Keeping dotfiles synchronized across multiple machines is
   challenging
4. **Team Inconsistency**: Different developers have different setups, leading to
   "works on my machine" issues
5. **Migration Difficulty**: Moving to new machines or platforms requires significant
   reconfiguration

## Differentiators

**vs. Omakub:**
- Cross-distribution support (Ubuntu, Fedora, Arch, etc.) vs Ubuntu-only
- Chezmoi's powerful templating vs basic shell scripts
- Modular architecture vs monolithic approach

**vs. Raw Chezmoi:**
- Pre-configured, opinionated setup vs starting from scratch
- Curated tool selection vs manual research and configuration
- Community-driven templates vs individual maintenance

**vs. Custom Dotfiles:**
- Professional maintenance and updates vs personal upkeep
- Cross-platform testing vs single-environment focus
- Community contributions vs isolated development

**Core Advantages:**
- **Cross-Distribution**: Works consistently across Linux distributions (Ubuntu, Fedora, Arch, etc.)
- **One-Command Setup**: Complete development environment in a single installation
- **Template-Driven**: Conditional configurations adapt to system characteristics
- **Modular Design**: Easy to customize, extend, or disable components
- **Battle-Tested**: Based on proven personal dotfiles system with real-world usage

## Key Features

**Installation & Setup:**
- One-command installation with chezmoi integration
- Multi-phase installation system (bootstrap → installers → configurations)
- Automatic system detection and conditional configuration
- Error handling and rollback capabilities

**Development Tools:**
- Neovim with LazyVim configuration
- Multiple editor support (Cursor, VS Code) with synchronized settings
- Git templates and configuration management
- Shell environment (Bash/Zsh) with modular script loading

**System Integration:**
- Desktop application creation for web apps
- Font installation and management
- dconf settings for GNOME desktop environments
- Docker Compose services for development tools (Ollama, OpenWebUI, PhotoPrism)

**Cross-Platform Support:**
- Linux distribution detection and adaptation
- Potential future macOS compatibility (not currently supported)
- Container environment detection and appropriate handling
- Platform-specific package management

**Customization & Extensibility:**
- Template-based configuration with Go templating
- Modular shell scripts in organized directories
- Easy addition of new applications and configurations
- Community contribution framework for new features
