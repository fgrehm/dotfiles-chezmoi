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
CYAN='\033[0;36m'
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

info() {
    echo -e "${CYAN}[INFO]${NC} $*"
}

check_bats() {
    if [ ! -x "$BATS_BIN" ]; then
        error "BATS not found. Run './test/bats-setup.sh' first."
        exit 1
    fi
}

run_test_suite() {
    local test_file="$1"
    local test_name="${test_file##*/}"

    log "Running test suite: $test_name"

    if [ -f "$test_file" ]; then
        "$BATS_BIN" "$test_file"
    else
        error "Test file not found: $test_file"
        return 1
    fi
}

run_all_tests() {
    log "Running all BATS tests..."

    local test_files=(
        "chezmoi-core.bats"
        "installers.bats"
        "configurations.bats"
        "chezmoi-templates.bats"
    )

    local failed=0

    for test_file in "${test_files[@]}"; do
        if [ -f "$SCRIPT_DIR/$test_file" ]; then
            if ! run_test_suite "$SCRIPT_DIR/$test_file"; then
                failed=1
            fi
        fi
    done

    if [ $failed -eq 0 ]; then
        success "All tests passed!"
        echo ""
        info "Testing Architecture:"
        echo "  🧪 BATS Tests: Fast, reliable unit/component testing"
        echo "  🎮 Playground: Interactive development sandbox"
        echo ""
        echo "Next steps:"
        echo "  • Run playground: ./test/chezmoi-playground.sh start"
        echo "  • Interactive shell: ./test/chezmoi-playground.sh shell"
        echo "  • Test templates: ./test/chezmoi-playground.sh test-template"
    else
        error "Some tests failed"
        exit 1
    fi
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    all         Run all BATS test suites
    core        Run chezmoi core tests
    installers  Run installer script tests
    configs     Run configuration tests
    templates   Run template tests
    help        Show this help

Examples:
    $0 all              # Run all BATS tests
    $0 core             # Run only core tests
    $0 installers       # Run only installer tests
    $0 templates        # Run only template tests

Testing Architecture:
    🧪 BATS Tests: Fast, reliable unit/component testing
    🎮 Playground: Interactive development sandbox (./test/chezmoi-playground.sh)

    BATS is for automated testing and CI/CD
    Playground is for development, debugging, and experimentation
EOF
}

main() {
    check_bats

    case "${1:-all}" in
        "all")
            run_all_tests
            ;;
        "core")
            run_test_suite "$SCRIPT_DIR/chezmoi-core.bats"
            ;;
        "installers")
            run_test_suite "$SCRIPT_DIR/installers.bats"
            ;;
        "configs")
            run_test_suite "$SCRIPT_DIR/configurations.bats"
            ;;
        "templates")
            run_test_suite "$SCRIPT_DIR/chezmoi-templates.bats"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
