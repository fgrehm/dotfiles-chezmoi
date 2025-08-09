#!/usr/bin/env bats

# Load test configuration
load "test-config.bash"

# Test chezmoi template behavior and syntax
@test "chezmoi template variables are accessible" {
    # Test basic variable access
    local test_template="Source: {{ .chezmoi.sourceDir }}"

    run chezmoi execute-template --init <<< "$test_template"
    assert_success
    assert_output --regexp '^Source: .*'
}

@test "template conditionals work correctly" {
    # Test various conditional expressions
    local test_cases=(
        "{{ if .chezmoi.os }}os-detected{{ else }}no-os{{ end }}"
        "{{ if .chezmoi.arch }}arch-detected{{ else }}no-arch{{ end }}"
    )

    for test_case in "${test_cases[@]}"; do
        echo "Testing: $test_case"
        run chezmoi execute-template --init <<< "$test_case"
        assert_success
        assert_output --regexp '^[a-zA-Z0-9_-]+$'
    done
}

@test "editor configuration templates are valid" {
    # Test editor configuration templates
    local editor_configs=(
        "configs/nvim/init.lua"
        "configs/cursor/settings.json"
        "configs/vscode/settings.json"
    )

    for config in "${editor_configs[@]}"; do
        if [ -f "$config" ]; then
            echo "Testing config: $config"

            if [[ "$config" == *.tmpl ]]; then
                run chezmoi execute-template < "$config"
                assert_success
            else
                # Non-template files should exist and be readable
                assert_file_exist "$config"
                assert [ -r "$config" ]
            fi
        fi
    done
}

@test "chezmoi configuration template is valid" {
    # Test the main configuration template
    test_template "home/.chezmoi.toml.tmpl" "data\.virt"
}

@test "installer script templates are valid" {
    # Test installer script templates
    local installer_dir="home/.chezmoiscripts/01-installers"

    if [ -d "$installer_dir" ]; then
        local script_count
        script_count=$(find "$installer_dir" -name "*.sh.tmpl" | wc -l)

        if [ "$script_count" -gt 0 ]; then
            find "$installer_dir" -name "*.sh.tmpl" | while read -r script; do
                echo "Testing installer script: $script"
                run chezmoi execute-template < "$script"
                assert_success
            done
        else
            skip "No installer script templates found"
        fi
    else
        skip "Installer scripts directory not found"
    fi
}

@test "bootstrap script templates are valid" {
    # Test bootstrap script templates
    local bootstrap_dir="home/.chezmoiscripts/00-bootstrap"

    if [ -d "$bootstrap_dir" ]; then
        local script_count
        script_count=$(find "$bootstrap_dir" -name "*.sh.tmpl" | wc -l)

        if [ "$script_count" -gt 0 ]; then
            find "$bootstrap_dir" -name "*.sh.tmpl" | while read -r script; do
                echo "Testing bootstrap script: $script"
                run chezmoi execute-template < "$script"
                assert_success
            done
        else
            skip "No bootstrap script templates found"
        fi
    else
        skip "Bootstrap scripts directory not found"
    fi
}

@test "shell configuration templates are valid" {
    # Test shell configuration templates
    local shell_configs=(
        "home/.bashrc.tmpl"
        "home/.zshrc.tmpl"
        "home/.profile.tmpl"
    )

    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ]; then
            echo "Testing shell config: $config"
            run chezmoi execute-template < "$config"
            assert_success
        fi
    done
}

@test "chezmoi init from source works" {
    # Test that chezmoi can initialize from the current source
    echo "Debug: Starting chezmoi init test" >&2

    local temp_dir
    temp_dir=$(mktemp -d)
    echo "Debug: Created temp dir: $temp_dir" >&2

    # Clean up on exit
    trap 'rm -rf "$temp_dir"' EXIT

    cd "$temp_dir"
    echo "Debug: Changed to temp dir: $(pwd)" >&2

    # Initialize chezmoi with the source directory
    echo "Debug: About to run: chezmoi init --source $REPO_ROOT" >&2
    run chezmoi init --source "$REPO_ROOT"
    echo "Debug: chezmoi init exit code: $status" >&2
    echo "Debug: chezmoi init output: $output" >&2
    assert_success

    # Check that it created the expected files
    echo "Debug: Checking for .chezmoi.toml in $(pwd)" >&2
    ls -la >&2
    assert_file_exist ".chezmoi.toml"
    echo "Debug: Test completed successfully" >&2
}
