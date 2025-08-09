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

check_bats() {
    if [ ! -x "$BATS_BIN" ]; then
        error "BATS not found. Run ./test/bats-setup.sh first"
        exit 1
    fi
}

run_test_suite() {
    local suite="$1"
    local test_file="$REPO_ROOT/test/${suite}.bats"
    
    if [ ! -f "$test_file" ]; then
        error "Test suite not found: $test_file"
        return 1
    fi
    
    log "Running $suite tests..."
    cd "$REPO_ROOT"
    "$BATS_BIN" "$test_file"
}

show_usage() {
    cat << USAGE_EOF
Usage: $0 [COMMAND]

Commands:
    all         Run all test suites
    core        Run core chezmoi tests
    templates   Run template validation tests
    installers  Run installer script tests
    configs     Run configuration tests
    help        Show this help

Examples:
    $0 all       # Run all tests
    $0 core      # Run just core tests
USAGE_EOF
}

main() {
    check_bats
    
    case "${1:-all}" in
        "all")
            log "Running all test suites..."
            run_test_suite "chezmoi-core"
            run_test_suite "chezmoi-templates" 
            run_test_suite "installers"
            run_test_suite "configurations"
            success "All tests completed!"
            ;;
        "core")
            run_test_suite "chezmoi-core"
            ;;
        "templates")
            run_test_suite "chezmoi-templates"
            ;;
        "installers")
            run_test_suite "installers"
            ;;
        "configs")
            run_test_suite "configurations"
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
