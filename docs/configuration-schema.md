# Chezmakase Configuration Schema

This document defines the configuration schema for optional components in chezmakase.

## Schema Overview

The configuration is structured in `.chezmoi.toml.tmpl` with the following categories:

```toml
[data.components]
    [data.components.editors]        # Text editors and IDEs
    [data.components.browsers]       # Web browsers  
    [data.components.development]    # Development tools and infrastructure
    [data.components.services]       # Docker services and self-hosted apps
    [data.components.desktop]        # Desktop applications
    [data.components.system]         # System-level configurations
    [data.components.security]       # Security and identity tools
```

## Component Categories

### Editors (`components.editors`)

Text editors and development environments:

```toml
[data.components.editors]
    cursor = true      # AI-powered code editor (recommended for AI development)
    nvim = true        # Modern Neovim with LazyVim configuration
    vscode = false     # Microsoft Visual Studio Code
```

**Recommendations:**

- **Cursor** for AI-assisted development
- **Neovim** for terminal-based editing
- **VS Code** for traditional IDE experience

### Browsers (`components.browsers`)

Web browsers and related tools:

```toml
[data.components.browsers]
    brave = true       # Privacy-focused browser with ad blocking
    firefox = false    # Mozilla Firefox (planned)
```

### Development (`components.development`)

Development tools and infrastructure:

```toml
[data.components.development]
    docker = true              # Docker container platform
    nodejs = true              # Node.js via NVM
    virtualbox = false         # VirtualBox virtualization (bare metal only)
    claude_cli = true          # Claude Code CLI (planned)
    shellcheck = true          # Bash script linting (planned)
    markdownlint = true        # Markdown linting tools (planned)
```

**Environment-Specific:**

- **VirtualBox** - Only installed on bare metal (skipped in containers)
- **Docker** - Skipped in containers (uses host Docker)

### Services (`components.services`)

Self-hosted services via Docker Compose:

```toml
[data.components.services]
    ollama = false            # Local LLM server
    openwebui = false         # Web interface for Ollama
    photoprism = false        # Photo management and AI tagging
    
    # Service dependencies
    auto_start = false        # Auto-start services with Docker
```

**Notes:**

- Services require Docker to be enabled
- Services are disabled by default (resource intensive)
- Only available on bare metal installations

### Desktop (`components.desktop`)

Desktop applications and web apps:

```toml
[data.components.desktop]
    notion = true             # Notion workspace (web app)
    whatsapp = true           # WhatsApp Web (web app)
    alacritty = false         # Modern terminal emulator (planned)
```

**Container Behavior:**

- All desktop apps are automatically disabled in containers
- Web apps create `.desktop` files for native-like experience

### System (`components.system`)

System-level configurations:

```toml
[data.components.system]
    fonts = true              # Development fonts (FiraCode, etc.)
    zsh_config = true         # Zsh shell configuration
    gnome_settings = true     # GNOME desktop settings via dconf
    package_updates = true    # System package installation and updates
```

**Container Behavior:**

- **GNOME settings** - Disabled in containers
- **Package updates** - Container-specific package lists
- **Fonts** - Always installed (needed for editors)

### Security (`components.security`)

Security and identity management:

```toml
[data.components.security]
    onepassword = true        # 1Password password manager (bare metal only)
    ssh_config = true         # SSH client configuration
    gpg_config = false        # GPG configuration (planned)
```

## Configuration Levels

### Basic Setup (Default)

Recommended configuration for most users:

```toml
[data.components.editors]
    cursor = true
    nvim = true
    vscode = false

[data.components.browsers]  
    brave = true

[data.components.development]
    docker = true
    nodejs = true
    claude_cli = true
    shellcheck = true
    markdownlint = true

[data.components.desktop]
    notion = true
    whatsapp = true

[data.components.system]
    fonts = true
    zsh_config = true
    gnome_settings = true
    package_updates = true

[data.components.security]
    onepassword = true
    ssh_config = true
```

### Minimal Setup

Lightweight configuration for containers or minimal installs:

```toml
[data.components.editors]
    cursor = false
    nvim = true
    vscode = false

[data.components.development]
    docker = false
    nodejs = true
    claude_cli = true
    shellcheck = true
    markdownlint = true

[data.components.system]
    fonts = true
    zsh_config = true
    package_updates = true
```

### Developer Setup

Full development environment:

```toml
# All components enabled except resource-intensive services
[data.components.services]
    ollama = false      # Enable manually if needed
    openwebui = false
    photoprism = false
```

## Environment-Specific Behavior

### Container Environments

Automatically disabled in containers:

- All desktop applications
- System-level configurations (GNOME, etc.)
- VirtualBox and hardware-dependent tools
- 1Password (requires system integration)

### Bare Metal

All components available based on user configuration.

## Implementation Strategy

### Phase 1: Core Configuration

1. Update `.chezmoi.toml.tmpl` with basic schema
2. Add component toggles to existing installer scripts
3. Test with current components

### Phase 2: User Experience  

1. Add interactive prompts for component selection
2. Provide setup profiles (basic, minimal, developer)
3. Add validation and error handling

### Phase 3: Advanced Features

1. Component dependencies and conflicts
2. Performance optimizations
3. Migration and upgrade handling

## Validation Rules

### Dependencies

- `openwebui` requires `ollama`
- Services require `docker`
- Desktop apps require bare metal environment

### Conflicts

- Multiple terminal emulators (warn user)
- Resource constraints in containers

### Environment Constraints

- Container environment disables incompatible components
- Missing system dependencies log warnings but continue
