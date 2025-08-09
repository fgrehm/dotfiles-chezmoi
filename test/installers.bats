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
