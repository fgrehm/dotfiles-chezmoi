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
