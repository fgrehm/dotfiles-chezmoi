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
