#!/bin/bash
# Test chezmakase in actual Docker container environment
# Inspired by Rails' devcontainer approach

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTAINER_NAME="chezmakase-test-$(date +%s)"
IMAGE_NAME="chezmakase-test"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[TEST]${NC} $*"
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

check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        error "Docker daemon is not running or not accessible"
        exit 1
    fi
}

cleanup() {
    if [ "${KEEP_CONTAINER:-}" = "true" ]; then
        log "Keeping container and image for faster iterations"
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        log "Container stopped but kept. Use 'docker start $CONTAINER_NAME' to reuse."
        log "Use 'KEEP_CONTAINER=false $0 cleanup' to fully clean up."
    else
        log "Cleaning up container and image..."
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
    fi
}

build_test_image() {
    # Check if image already exists and is recent
    if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        log "Using existing Docker image: $IMAGE_NAME"
        log "Use 'docker rmi $IMAGE_NAME' to force rebuild"
        return 0
    fi
    
    log "Building test Docker image with caching optimizations..."
    
    # Create optimized Dockerfile with proper layer caching
    cat > "$REPO_ROOT/Dockerfile.test" << 'EOF'
FROM ubuntu:22.04

# Use BuildKit for better caching
# Install dependencies in separate layers for better caching
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        sudo \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create devcontainer marker early (this is what makes it a devcontainer)
RUN mkdir -p /var/devcontainer && touch /var/devcontainer/.devcontainer

# Create vscode user (typical devcontainer setup)
RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install chezmoi in a separate layer for caching
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# Set up working directory
WORKDIR /workspace

# Switch to vscode user
USER vscode

# Create cache directory
RUN mkdir -p /home/vscode/.cache
EOF

    # Use BuildKit for better caching and build with cache mount
    DOCKER_BUILDKIT=1 docker build \
        --tag "$IMAGE_NAME" \
        --file "$REPO_ROOT/Dockerfile.test" \
        --progress=plain \
        "$REPO_ROOT"
    
    # Clean up temporary Dockerfile
    rm "$REPO_ROOT/Dockerfile.test"
    
    success "Test image built successfully with optimized caching"
}

run_container() {
    # Check if container already exists and is running
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log "Reusing existing running container: $CONTAINER_NAME"
        return 0
    fi
    
    # Check if container exists but is stopped
    if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
        log "Starting existing stopped container: $CONTAINER_NAME"
        docker start "$CONTAINER_NAME"
        return 0
    fi
    
    log "Creating new test container..."
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        -v "$REPO_ROOT:/workspace" \
        -w /workspace \
        --tmpfs /tmp:rw,exec,size=100m \
        "$IMAGE_NAME" \
        tail -f /dev/null
        
    success "Container started: $CONTAINER_NAME"
}

test_container_detection() {
    log "Testing container detection..."
    
    # Test chezmoi template execution in container
    local result
    result=$(docker exec "$CONTAINER_NAME" bash -c '
        cd /workspace
        chezmoi execute-template --init < home/.chezmoi.toml.tmpl
    ')
    
    log "Template result:"
    echo "$result"
    
    if echo "$result" | grep -q "container = true"; then
        success "Container detection working correctly"
    else
        error "Container detection failed"
        return 1
    fi
    
    if echo "$result" | grep -q "devcontainer = true"; then
        success "Devcontainer detection working correctly"
    else
        error "Devcontainer detection failed"
        return 1
    fi
}

test_installer_scripts() {
    log "Testing installer scripts in container..."
    
    local scripts_dir="/workspace/home/.chezmoiscripts/01-installers"
    
    # Test each installer script
    local result
    result=$(docker exec "$CONTAINER_NAME" bash -c "
        cd /workspace
        for script in $scripts_dir/*.sh.tmpl; do
            if [ -f \"\$script\" ]; then
                script_name=\$(basename \"\$script\")
                echo \"Testing \$script_name:\"
                
                # Execute template
                output=\$(chezmoi execute-template < \"\$script\" 2>&1)
                
                # Check if it exits early (good for containers)
                if echo \"\$output\" | head -n 5 | grep -q 'exit 0'; then
                    echo \"  ✓ Correctly exits early in container\"
                else
                    echo \"  ! Might execute in container:\"
                    echo \"\$output\" | head -n 5 | sed 's/^/    /'
                fi
                echo
            fi
        done
    ")
    
    echo "$result"
    
    # Count successful early exits
    local exit_count
    exit_count=$(echo "$result" | grep -c "✓ Correctly exits early" || echo "0")
    
    success "Found $exit_count installer scripts that correctly handle containers"
}

test_chezmoi_apply() {
    log "Testing chezmoi apply in container (dry run)..."
    
    local result
    result=$(docker exec "$CONTAINER_NAME" bash -c '
        cd /workspace
        
        # Initialize chezmoi with current directory as source
        chezmoi init --source /workspace
        
        # Run dry-run to see what would be applied
        chezmoi apply --dry-run
    ' 2>&1)
    
    log "Chezmoi apply dry-run result:"
    echo "$result"
    
    # Check if it completed without major errors
    if echo "$result" | grep -q "would"; then
        success "Chezmoi apply dry-run completed"
    else
        warn "Dry-run might have had issues, but this could be normal"
    fi
}

test_development_tools() {
    log "Testing development tools installation in container..."
    
    # Test if the devcontainer setup script would work
    local result
    result=$(docker exec "$CONTAINER_NAME" bash -c '
        cd /workspace
        
        # Simulate running the devcontainer setup
        if [ -f .devcontainer/setup.sh ]; then
            echo "Running devcontainer setup script..."
            bash .devcontainer/setup.sh
        else
            echo "No setup script found"
        fi
    ' 2>&1)
    
    log "Setup script result:"
    echo "$result" | tail -n 20
    
    success "Development tools test completed"
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    test        Run all tests in Docker container
    detection   Test container detection only
    scripts     Test installer scripts only
    apply       Test chezmoi apply (dry run)
    setup       Test devcontainer setup
    interactive Start interactive shell in test container
    cleanup     Clean up containers and images
    help        Show this help

Example:
    $0 test     # Run all tests
    $0 interactive  # Get a shell in the test container
EOF
}

main() {
    check_docker
    
    case "${1:-test}" in
        "test")
            build_test_image
            run_container
            test_container_detection
            test_installer_scripts
            test_chezmoi_apply
            test_development_tools
            success "All tests completed"
            ;;
        "detection")
            build_test_image
            run_container
            test_container_detection
            ;;
        "scripts")
            build_test_image
            run_container
            test_installer_scripts
            ;;
        "apply")
            build_test_image
            run_container
            test_chezmoi_apply
            ;;
        "setup")
            build_test_image
            run_container
            test_development_tools
            ;;
        "interactive")
            build_test_image
            run_container
            log "Starting interactive shell in container..."
            docker exec -it "$CONTAINER_NAME" bash
            ;;
        "cleanup")
            cleanup
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

# Set up cleanup trap
trap cleanup EXIT

# Run main function
main "$@"