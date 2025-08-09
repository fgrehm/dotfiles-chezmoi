# Chezmoi Testing Framework

This directory contains the testing infrastructure for chezmakase, designed with a clean separation of concerns:

- **🧪 BATS Tests**: Fast, reliable unit and component testing
- **🎮 Development Playground**: Interactive sandbox for development and debugging

## Architecture Overview

### BATS Testing Framework

Fast, lightweight testing using the Bash Automated Testing System (BATS). Perfect for:
- Template validation
- Script syntax checking
- Configuration file validation
- CI/CD automation

### Development Playground

Interactive Docker-based environment for:
- Manual testing and debugging
- Template experimentation
- Real container environment testing
- Development workflow validation

## Quick Start

### 1. Setup BATS Framework

```bash
./test/bats-setup.sh
```

### 2. Run Tests

```bash
# Run all tests
./test/run-tests.sh all

# Run specific test suite
./test/run-tests.sh templates
./test/run-tests.sh installers
./test/run-tests.sh configs
./test/run-tests.sh core
```

### 3. Start Development Playground

```bash
# Start playground container
./test/chezmoi-playground.sh start

# Interactive shell
./test/chezmoi-playground.sh shell

# Test specific template
./test/chezmoi-playground.sh test-template home/.chezmoi.toml.tmpl

# Test chezmoi operations
./test/chezmoi-playground.sh dry-run
./test/chezmoi-playground.sh status
```

## Test Categories

### BATS Test Suites

#### `chezmoi-core.bats`

- Basic chezmoi functionality
- Version and command availability
- Core template execution

#### `installers.bats`

- Installer script existence and syntax
- Bootstrap script validation
- Template execution for scripts

#### `configurations.bats`

- Configuration file existence
- Shell configuration validation
- Editor configuration checks

#### `chezmoi-templates.bats`

- Template syntax validation
- Variable accessibility testing
- Conditional logic testing
- Script template validation

### Development Playground

The playground provides a real container environment for:
- **Interactive Development**: Get a shell in a containerized environment
- **Template Testing**: Test templates with real container detection
- **Integration Testing**: Test actual chezmoi operations
- **Debugging**: Investigate issues in a controlled environment

## Configuration

### Test Configuration

- `test-config.bash`: Common test setup and helper functions
- Environment variables for chezmoi testing
- Container detection helpers

### Playground Configuration

- Docker-based Ubuntu 22.04 environment
- Pre-installed development tools (vim, git, tree, etc.)
- Chezmoi and additional utilities (yamllint, shellcheck)
- Convenient aliases for common operations

## Writing New Tests

### Adding BATS Tests

1. Create a new `.bats` file in the `test/` directory
2. Load the test configuration: `load "test-config.bash"`
3. Write test functions with `@test` annotations
4. Use BATS assertions: `assert_success`, `assert_output`, etc.

Example:
```bash
@test "my new feature works" {
    run my_command
    assert_success
    assert_output --regexp "expected pattern"
}
```

### Using the Playground

The playground is perfect for:
- Testing new templates interactively
- Debugging chezmoi apply issues
- Experimenting with different configurations
- Manual validation of container behavior

## CI/CD Integration

### GitHub Actions

The `.github/workflows/test.yml` workflow:
- Runs BATS tests on every push/PR
- Ensures code quality and template validity
- Provides fast feedback on changes

### Local Development

- Run BATS tests locally: `./test/run-tests.sh all`
- Use playground for development: `./test/chezmoi-playground.sh shell`
- Keep containers for faster iterations: `KEEP_CONTAINER=true ./test/chezmoi-playground.sh start`

## Maintenance

### Updating BATS
```bash
cd test/bats
git pull origin main  # For each BATS library
```

### Rebuilding Playground
```bash
docker rmi chezmoi-playground
./test/chezmoi-playground.sh start
```

### Cleaning Up
```bash
# Clean up playground containers
./test/chezmoi-playground.sh cleanup

# Clean up BATS (if needed)
rm -rf test/bats/
./test/bats-setup.sh
```

## Best Practices

### BATS Tests

- Keep tests focused and atomic
- Use descriptive test names
- Test both success and failure cases
- Use appropriate assertions for the expected behavior

### Playground Usage

- Use for interactive development and debugging
- Test real-world scenarios
- Validate container-specific behavior
- Experiment with template changes

### General

- Run BATS tests before committing
- Use playground for complex debugging
- Keep tests fast and reliable
- Document any special testing requirements

## Troubleshooting

### Common Issues

#### BATS Tests Failing

- Ensure BATS is properly installed: `./test/bats-setup.sh`
- Check test configuration: `test-config.bash`
- Verify chezmoi is available in PATH

#### Playground Issues

- Check Docker is running: `docker info`
- Rebuild playground image: `docker rmi chezmoi-playground`
- Check container logs: `docker logs <container-name>`

#### Template Issues

- Validate template syntax: `chezmoi execute-template --init < template.tmpl`
- Check variable availability: `chezmoi data`
- Use playground for interactive debugging

### Getting Help

- Check test output for specific error messages
- Use playground for interactive debugging
- Review BATS documentation for assertion usage
- Check chezmoi documentation for template syntax

## File Structure

```
test/
├── bats/                    # BATS framework and libraries
├── chezmoi-core.bats       # Core functionality tests
├── installers.bats         # Installer script tests
├── configurations.bats     # Configuration file tests
├── chezmoi-templates.bats  # Template validation tests
├── test-config.bash        # Test configuration and helpers
├── run-tests.sh            # BATS test runner
├── chezmoi-playground.sh   # Development playground
├── bats-setup.sh           # BATS installation script
└── README.md               # This file
```

This architecture provides the best of both worlds: fast, reliable automated testing with BATS, and a powerful development environment with the playground for interactive work.
