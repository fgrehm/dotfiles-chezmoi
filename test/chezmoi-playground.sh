#!/bin/bash
# Chezmoi Development Playground
# A sandbox environment for testing, debugging, and experimenting with chezmoi

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTAINER_NAME="chezmoi-playground-$(date +%s)"
IMAGE_NAME="chezmoi-playground"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[PLAYGROUND]${NC} $*"
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

info() {
    echo -e "${CYAN}[INFO]${NC} $*"
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
    if [ "${KEEP_CONTAINER:-}" = "false" ]; then
        log "Cleaning up playground container and image..."
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
    else
        log "Keeping playground container for faster iterations"
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        log "Container stopped but kept. Use 'docker start $CONTAINER_NAME' to reuse."
        log "Use 'KEEP_CONTAINER=false $0 cleanup' to fully clean up."
    fi
}

build_playground_image() {
    # Check if image already exists and is recent
    if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        log "Using existing playground image: $IMAGE_NAME"
        log "Use 'docker rmi $IMAGE_NAME' to force rebuild"
        return 0
    fi

    log "Building playground Docker image..."

    # Create optimized Dockerfile for development
    cat > "$REPO_ROOT/Dockerfile.playground" << 'EOF'
FROM ubuntu:22.04

# Install development dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        sudo \
        vim \
        nano \
        tree \
        htop \
        less \
        man-db \
        build-essential \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create devcontainer marker
RUN mkdir -p /var/devcontainer && touch /var/devcontainer/.devcontainer

# Create vscode user
RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# Install additional development tools
RUN pip3 install --no-cache-dir \
    yamllint \
    shellcheck

# Set up working directory
WORKDIR /workspace

# Switch to vscode user
USER vscode

# Create cache directory and set up shell
RUN mkdir -p /home/vscode/.cache && \
    echo 'export PS1="\[\033[01;32m\]chezmoi-playground\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/vscode/.bashrc

# Set up aliases for common operations
RUN echo 'alias c="chezmoi"' >> /home/vscode/.bashrc && \
    echo 'alias ca="chezmoi apply"' >> /home/vscode/.bashrc && \
    echo 'alias cdry="chezmoi apply --dry-run"' >> /home/vscode/.bashrc && \
    echo 'alias ct="chezmoi execute-template"' >> /home/vscode/.bashrc && \
    echo 'alias cdiff="chezmoi diff"' >> /home/vscode/.bashrc && \
    echo 'alias cstatus="chezmoi status"' >> /home/vscode/.bashrc
EOF

    # Build with BuildKit for better caching
    DOCKER_BUILDKIT=1 docker build \
        --tag "$IMAGE_NAME" \
        --file "$REPO_ROOT/Dockerfile.playground" \
        --progress=plain \
        "$REPO_ROOT"

    # Clean up temporary Dockerfile
    rm "$REPO_ROOT/Dockerfile.playground"

    success "Playground image built successfully"
}

start_playground() {
    # Check if container already exists and is running
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log "Reusing existing playground container: $CONTAINER_NAME"
        return 0
    fi

    # Check if container exists but is stopped
    if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
        log "Starting existing stopped playground container: $CONTAINER_NAME"
        docker start "$CONTAINER_NAME"
        return 0
    fi

    log "Creating new playground container..."

    docker run -d \
        --name "$CONTAINER_NAME" \
        -v "$REPO_ROOT:/workspace" \
        -w /workspace \
        --tmpfs /tmp:rw,exec,size=100m \
        -p 8080:8080 \
        "$IMAGE_NAME" \
        tail -f /dev/null

    success "Playground started: $CONTAINER_NAME"
}

show_playground_info() {
    log "Playground Container Info:"
    echo "  Container: $CONTAINER_NAME"
    echo "  Image: $IMAGE_NAME"
    echo "  Status: $(docker ps --filter name="$CONTAINER_NAME" --format '{{.Status}}')"
    echo "  Ports: 8080 (if you add web services)"
    echo ""
    echo "Quick Commands:"
    echo "  $0 shell          # Interactive shell"
    echo "  $0 test-template  # Test a specific template"
    echo "  $0 dry-run        # Test chezmoi apply (dry run)"
    echo "  $0 status         # Check chezmoi status"
    echo ""
    echo "Container Access:"
    echo "  docker exec -it $CONTAINER_NAME bash"
}

test_template_interactive() {
    local template_file="$1"

    if [ -z "$template_file" ]; then
        log "Available templates:"
        find . -name "*.tmpl" -type f | head -20
        echo ""
        read -p "Enter template path to test: " template_file
    fi

    if [ ! -f "$template_file" ]; then
        error "Template file not found: $template_file"
        return 1
    fi

    log "Testing template: $template_file"

    # Test template execution
    local result
    result=$(docker exec "$CONTAINER_NAME" bash -c "
        cd /workspace
        echo 'Template: $template_file'
        echo '---'
        chezmoi execute-template --init < '$template_file'
        echo '---'
        echo 'Variables available:'
        chezmoi data | head -10
    ")

    echo "$result"
}

test_chezmoi_operations() {
    local operation="$1"

    case "$operation" in
        "dry-run")
            log "Testing chezmoi apply (dry run)..."
            docker exec "$CONTAINER_NAME" bash -c "
                cd /workspace
                chezmoi init --source /workspace
                chezmoi apply --dry-run
            "
            ;;
        "status")
            log "Checking chezmoi status..."
            docker exec "$CONTAINER_NAME" bash -c "
                cd /workspace
                chezmoi init --source /workspace
                chezmoi status
            "
            ;;
        "diff")
            log "Showing chezmoi diff..."
            docker exec "$CONTAINER_NAME" bash -c "
                cd /workspace
                chezmoi init --source /workspace
                chezmoi diff
            "
            ;;
        *)
            error "Unknown operation: $operation"
            return 1
            ;;
    esac
}

interactive_shell() {
    log "Starting interactive shell in playground..."
    log "Available aliases: c (chezmoi), ca (apply), cdry (dry-run), ct (template), cdiff (diff), cstatus (status)"
    docker exec -it "$CONTAINER_NAME" bash
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    start       Start the playground container
    shell       Interactive shell in playground
    test-template [FILE]  Test a specific template file
    dry-run     Test chezmoi apply (dry run)
    status      Check chezmoi status
    diff        Show chezmoi diff
    info        Show playground information
    cleanup     Clean up containers and images
    help        Show this help

Examples:
    $0 start              # Start playground
    $0 shell              # Get interactive shell
    $0 test-template      # Test a template interactively
    $0 test-template home/.chezmoi.toml.tmpl  # Test specific template
    $0 dry-run            # Test chezmoi operations
    $0 status             # Check current status

Environment Variables:
    KEEP_CONTAINER=true   Keep container after exit (faster iterations)
EOF
}

main() {
    check_docker

    case "${1:-help}" in
        "start")
            build_playground_image
            start_playground
            show_playground_info
            ;;
        "shell")
            start_playground
            interactive_shell
            ;;
        "test-template")
            start_playground
            test_template_interactive "$2"
            ;;
        "dry-run")
            start_playground
            test_chezmoi_operations "dry-run"
            ;;
        "status")
            start_playground
            test_chezmoi_operations "status"
            ;;
        "diff")
            start_playground
            test_chezmoi_operations "diff"
            ;;
        "info")
            start_playground
            show_playground_info
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
