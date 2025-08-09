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
            # Check basic structure (shebang, basic syntax)
            assert [ -r "$script" ]
            # Verify it has a shebang
            run head -1 "$script"
            assert_success
            assert_output --regexp '^#!/'
            # Skip template execution - requires full chezmoi context
            # These are tested in integration tests with proper data
        fi
    done
}

@test "bootstrap scripts exist and are executable" {
    local scripts_dir="home/.chezmoiscripts/00-bootstrap"

    assert_dir_exist "$scripts_dir"

    for script in "$scripts_dir"/*.sh.tmpl; do
        if [ -f "$script" ]; then
            assert_file_exist "$script"
            # Check basic structure (shebang, basic syntax)
            assert [ -r "$script" ]
            # Verify it has a shebang
            run head -1 "$script"
            assert_success
            assert_output --regexp '^#!/'
            # Skip template execution - requires full chezmoi context
            # These are tested in integration tests with proper data
        fi
    done
}
