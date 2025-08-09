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
