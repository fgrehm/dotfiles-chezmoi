#!/bin/bash
# BATS testing framework setup for chezmakase
# This script installs BATS and sets up the testing environment

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BATS_DIR="$REPO_ROOT/test/bats"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[BATS-SETUP]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

install_bats() {
    log "Installing BATS testing framework..."

    if [ -d "$BATS_DIR" ]; then
        log "BATS directory already exists, updating..."
        rm -rf "$BATS_DIR"
    fi

    mkdir -p "$BATS_DIR"
    cd "$BATS_DIR"

    # Clone BATS core
    log "Installing bats-core..."
    git clone --depth 1 https://github.com/bats-core/bats-core.git bats-core

    # Clone BATS support
    log "Installing bats-support..."
    git clone --depth 1 https://github.com/bats-core/bats-support.git bats-support

    # Clone BATS assert
    log "Installing bats-assert..."
    git clone --depth 1 https://github.com/bats-core/bats-assert.git bats-assert

    # Clone BATS file
    log "Installing bats-file..."
    git clone --depth 1 https://github.com/bats-core/bats-file.git bats-file

    # Make bats executable
    chmod +x bats-core/bin/bats

    success "BATS framework installed successfully"
}

setup_test_environment() {
    log "Setting up test environment..."

    # Create test configuration
    cat > "$REPO_ROOT/test/test-config.sh" << 'EOF'
#!/bin/bash
# Test configuration and helper functions for chezmakase BATS tests

# Source BATS libraries
load "$REPO_ROOT/test/bats/bats-support/load.bash"
load "$REPO_ROOT/test/bats/bats-assert/load.bash"
load "$REPO_ROOT/test/bats/bats-file/load.bash"

# Test configuration
export CHEZMOI_ROOT="$REPO_ROOT"
export CHEZMOI_SOURCE="$REPO_ROOT"
export CHEZMOI_CONFIG="$REPO_ROOT/test/test-config.toml"

# Helper functions
setup_chezmoi_test() {
    # Create temporary chezmoi config for testing
    cat > "$CHEZMOI_CONFIG" << 'INNER_EOF'
sourceDir = "{{ .chezmoi.sourceDir }}"
data = { chezmoi = { sourceDir = "{{ .chezmoi.sourceDir }}" } }
INNER_EOF
}

cleanup_chezmoi_test() {
    rm -f "$CHEZMOI_CONFIG"
}

# Container detection helpers
is_container() {
    [ -f /.dockerenv ] || [ -f /var/devcontainer/.devcontainer ]
}

is_devcontainer() {
    [ -f /var/devcontainer/.devcontainer ]
}

# Chezmoi template testing helpers
test_template() {
    local template_file="$1"
    local expected_pattern="$2"

    run chezmoi execute-template --init < "$template_file"
    assert_success
    assert_output --regexp "$expected_pattern"
}

# Script testing helpers
test_script_execution() {
    local script_file="$1"
    local expected_exit="$2"

    if [ -n "$expected_exit" ]; then
        run bash "$script_file"
        assert_equal "$status" "$expected_exit"
    else
        run bash "$script_file"
        assert_success
    fi
}
EOF

    chmod +x "$REPO_ROOT/test/test-config.sh"

    success "Test environment configured"
}

create_sample_tests() {
    log "Creating sample test files..."

    # Create main test suite
    cat > "$REPO_ROOT/test/chezmoi-core.bats" << 'EOF'
#!/usr/bin/env bats

# Load test configuration
load "test-config"

setup() {
    setup_chezmoi_test
}

teardown() {
    cleanup_chezmoi_test
}

@test "chezmoi template execution works" {
    run chezmoi --version
    assert_success
    assert_output --regexp "chezmoi version"
}

@test "container detection template works" {
    test_template "home/.chezmoi.toml.tmpl" "container.*=.*true"
}

@test "devcontainer detection template works" {
    test_template "home/.chezmoi.toml.tmpl" "devcontainer.*=.*true"
}
EOF

    # Create installer script tests
    cat > "$REPO_ROOT/test/installers.bats" << 'EOF'
#!/usr/bin/env bats

# Load test configuration
load "test-config"

setup() {
    setup_chezmoi_test
}

teardown() {
    cleanup_chezmoi_test
}

@test "installer scripts exist and are executable" {
    local scripts_dir="home/.chezmoiscripts/01-installers"

    assert_dir_exist "$scripts_dir"

    for script in "$scripts_dir"/*.sh.tmpl; do
        if [ -f "$script" ]; then
            assert_file_exist "$script"
            # Test template execution
            run chezmoi execute-template < "$script"
            assert_success
        fi
    done
}

@test "bootstrap scripts exist and are executable" {
    local scripts_dir="home/.chezmoiscripts/00-bootstrap"

    assert_dir_exist "$scripts_dir"

    for script in "$scripts_dir"/*.sh.tmpl; do
        if [ -f "$script" ]; then
            assert_file_exist "$script"
            # Test template execution
            run chezmoi execute-template < "$script"
            assert_success
        fi
    done
}
EOF

    # Create configuration tests
    cat > "$REPO_ROOT/test/configurations.bats" << 'EOF'
#!/usr/bin/env bats

# Load test configuration
load "test-config"

setup() {
    setup_chezmoi_test
}

teardown() {
    cleanup_chezmoi_test
}

@test "chezmoi configuration files exist" {
    assert_file_exist "home/.chezmoi.toml.tmpl"
    assert_file_exist "home/.chezmoiscripts/00-bootstrap/01-system-update.sh.tmpl"
}

@test "shell configuration files exist" {
    assert_file_exist "home/dot_bashrc"
    assert_file_exist "home/dot_zshrc"
    assert_dir_exist "home/dot_shell.d"
}

@test "editor configurations exist" {
    assert_dir_exist "configs/nvim"
    assert_dir_exist "configs/cursor"
    assert_dir_exist "configs/vscode"
}
EOF

    chmod +x "$REPO_ROOT/test/"*.bats

    success "Sample test files created"
}

create_test_runner() {
    log "Creating test runner script..."

    cat > "$REPO_ROOT/test/run-tests.sh" << 'EOF'
#!/bin/bash
# BATS test runner for chezmakase

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BATS_BIN="$REPO_ROOT/test/bats/bats-core/bin/bats"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[TEST-RUNNER]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}



# Run main function
main "$@"
EOF

    chmod +x "$REPO_ROOT/test/run-tests.sh"

    success "Test runner created"
}

update_gitignore() {
    log "Updating .gitignore for BATS..."

    if [ -f "$REPO_ROOT/.gitignore" ]; then
        # Check if BATS is already ignored
        if ! grep -q "test/bats/" "$REPO_ROOT/.gitignore"; then
            echo "" >> "$REPO_ROOT/.gitignore"
            echo "# BATS testing framework" >> "$REPO_ROOT/.gitignore"
            echo "test/bats/" >> "$REPO_ROOT/.gitignore"
            echo "test/test-config.toml" >> "$REPO_ROOT/.gitignore"
            success "Updated .gitignore"
        else
            log ".gitignore already updated"
        fi
    else
        warn "No .gitignore found, creating one..."
        cat > "$REPO_ROOT/.gitignore" << 'EOF'
# BATS testing framework
test/bats/
test/test-config.toml
EOF
        success "Created .gitignore"
    fi
}

main() {
    log "Setting up BATS testing framework for chezmakase..."

    install_bats
    setup_test_environment
    create_sample_tests
    create_test_runner
    update_gitignore

    success "BATS setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Run tests: ./test/run-tests.sh"
    echo "2. Run specific test suite: ./test/run-tests.sh core"
    echo "3. Add more tests to the .bats files"
    echo ""
    echo "Your existing ./test/simulate-devcontainer.sh remains for Docker-specific testing"
}

# Run main function
main "$@"
