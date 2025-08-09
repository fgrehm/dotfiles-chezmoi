# Chezmoi Best Practices

This document outlines best practices for using chezmoi in the chezmakase dotfiles system.

## Configuration Management

### Data Configuration

Use `.chezmoi.toml.tmpl` for machine-specific configuration that can prompt users during
initialization:

```toml
{{- $email := promptStringOnce . "email" "Email address" -}}
{{- $fullName := promptStringOnce . "fullName" "Full name" -}}

[data]
    email = {{ $email | quote }}
    fullName = {{ $fullName | quote }}
```

### Component Configuration

For optional components, use structured data with sensible defaults:

```toml
[data.components]
    # Development tools
    [data.components.editors]
        cursor = true
        nvim = true
        vscode = false
    
    # Services
    [data.components.services]
        docker = true
        ollama = false
        photoprism = false
```

### Environment Detection

Combine environment detection with user preferences:

```toml
{{ $devcontainer := not (empty (stat "/var/devcontainer")) -}}
{{ $isContainer := or (env "container") $devcontainer -}}

[data.virt]
    container = {{ $isContainer }}
    devcontainer = {{ $devcontainer }}
```

## Template Patterns

### Conditional Installation

Use consistent patterns for optional components:

```bash
#!/bin/bash
# vi: ft=bash
{{ if not .components.editors.cursor }}exit 0{{ end }}
{{ if .virt.container }}exit 0{{ end }}

set -eo pipefail
# Installation logic here...
```

### Component Categories

Group related components logically:

- **Core Tools**: Essential development tools (git, shell, etc.)
- **Editors**: Text editors and IDEs (cursor, nvim, vscode)
- **Browsers**: Web browsers (brave, firefox)
- **Services**: Docker services (ollama, photoprism)
- **Desktop Apps**: GUI applications (notion, whatsapp)
- **System Config**: OS-level configurations (dconf, fonts)

### Data Validation

Validate configuration data in templates:

```toml
{{- if not (hasKey . "components") -}}
{{-   writeToStdout "Error: components configuration missing\n" -}}
{{-   exit 1 -}}
{{- end -}}
```

## Script Organization

### Naming Conventions

- `run_once_install-<component>.sh.tmpl` - Install applications
- `run_once_configure-<component>.sh.tmpl` - Configure applications
- `run_onchange_<action>.sh.tmpl` - Scripts that re-run when template changes

### Error Handling

Always include proper error handling:

```bash
#!/bin/bash
set -eo pipefail  # Exit on error or undefined variable

# Check prerequisites
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed"
    exit 1
fi
```

### Container Awareness

Make scripts container-aware:

```bash
# Skip GUI applications in containers
{{ if .virt.container }}exit 0{{ end }}

# Skip system-level configurations in containers
{{ if .virt.container }}exit 0{{ end }}
```

## User Experience

### Prompting Strategy

- Use `promptStringOnce` for values that shouldn't change between runs
- Provide sensible defaults
- Group related prompts together
- Validate input where possible

### Progressive Disclosure

Start with essential configuration, allow advanced users to customize:

```toml
{{- $basicSetup := promptBoolOnce . "basicSetup" "Use basic setup" true -}}

{{ if not $basicSetup }}
# Advanced configuration prompts
{{- $customEditor := promptChoiceOnce . "editor" "Choose editor" (list "cursor" "nvim" "vscode") "cursor" -}}
{{ end }}
```

### Documentation

Document configuration options:

```toml
# Editor Configuration
# - cursor: AI-powered code editor (recommended)
# - nvim: Terminal-based editor with modern plugins
# - vscode: Microsoft Visual Studio Code
[data.components.editors]
    cursor = true
    nvim = true
    vscode = false
```

## Security Considerations

### Private Data

Use `private_` prefix for sensitive files:

```text
home/private_dot_ssh/private_config.tmpl
home/private_dot_config/private_secrets.yaml.tmpl
```

### External Sources

Verify checksums when downloading from external sources:

```bash
curl -L "https://example.com/file" -o file
echo "expected_checksum  file" | sha256sum -c
```

### Conditional Secrets

Only include secrets when needed:

```bash
{{ if not .virt.container }}
# Only configure secrets on bare metal
export SECRET_KEY="{{ .secrets.apiKey }}"
{{ end }}
```

## Testing Strategy

### Template Testing

Test templates with different configurations:

```bash
# Test with different data contexts
echo '{"components":{"editors":{"cursor":false}}}' | chezmoi execute-template < script.sh.tmpl
```

### Environment Testing

Test in multiple environments:

- Bare metal installations
- Container environments
- Different OS distributions
- Fresh vs. existing installations

## Performance Optimization

### Efficient Conditionals

Use early exits for performance:

```bash
{{ if not .components.services.docker }}exit 0{{ end }}
{{ if .virt.container }}exit 0{{ end }}

# Only expensive operations run if conditions are met
```

### Caching

Cache expensive operations:

```bash
if [ -f "$HOME/.cache/component-installed" ]; then
    exit 0
fi

# Expensive installation
# ...

touch "$HOME/.cache/component-installed"
```

## Maintenance

### Version Compatibility

Document version requirements:

```bash
# Requires Ubuntu 20.04+ or equivalent
if ! command -v lsb_release >/dev/null 2>&1; then
    echo "Warning: Cannot detect OS version"
fi
```

### Migration Strategy

Handle configuration changes gracefully:

```toml
{{- $oldConfig := .oldConfig | default dict -}}
{{- $newFeature := $oldConfig.enableNewFeature | default true -}}

[data.features]
    newFeature = {{ $newFeature }}
```

