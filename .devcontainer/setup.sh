#!/bin/bash

set -eo pipefail

echo "🚀 Setting up Chezmakase development environment..."

# Ensure we're working as the correct user
echo "Current user: $(whoami)"
echo "Home directory: $HOME"

# Create the devcontainer marker that chezmoi uses for detection
sudo mkdir -p /var/devcontainer
sudo touch /var/devcontainer/.devcontainer

# Install chezmoi
echo "📦 Installing chezmoi..."
if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
fi

# Install essential packages for development
echo "📦 Installing development tools..."
sudo apt update
sudo apt install -y --no-install-recommends \
    curl \
    wget \
    git \
    vim \
    nano \
    tree \
    jq \
    shellcheck \
    ripgrep \
    fd-find \
    bat \
    htop \
    unzip \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release

# Install markdownlint-cli2
echo "📝 Installing markdownlint-cli2..."
if command -v npm >/dev/null 2>&1; then
    npm install -g markdownlint-cli2
fi

# Clone the chezmakase repository if not already present
if [ ! -d "/workspaces/chezmakase" ]; then
    echo "📁 Repository not found in /workspaces, checking current directory..."
    if [ -f ".chezmoiroot" ]; then
        echo "✅ Already in chezmakase repository"
    else
        echo "ℹ️  To test chezmakase installation, you'll need to initialize it manually:"
        echo "   chezmoi init --verbose fgrehm/dotfiles-chezmoi"
        echo "   (Note: This will test the actual installation process)"
    fi
else
    echo "✅ Chezmakase repository found at /workspaces/chezmakase"
fi

# Set up git configuration for development (using safe defaults)
echo "🔧 Setting up git configuration..."
git config --global --get user.name >/dev/null 2>&1 || git config --global user.name "Devcontainer User"
git config --global --get user.email >/dev/null 2>&1 || git config --global user.email "dev@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false

# Make the setup script executable
chmod +x /workspaces/*/(.devcontainer/setup.sh) 2>/dev/null || true

echo "✅ Chezmakase development environment setup complete!"
echo ""
echo "🔍 To test the chezmakase installation in this devcontainer:"
echo "   1. Run: chezmoi init --verbose fgrehm/dotfiles-chezmoi"
echo "   2. Apply with: chezmoi apply"
echo "   3. Check what would be installed: chezmoi diff"
echo ""
echo "📚 Useful commands:"
echo "   - chezmoi --help                  # Get help with chezmoi commands"
echo "   - chezmoi doctor                  # Check chezmoi setup"
echo "   - markdownlint-cli2 '**/*.md'     # Lint markdown files"
echo "   - shellcheck **/*.sh             # Check shell scripts"
echo ""
echo "🐳 Docker is available for testing docker-compose services"
echo "   - docker --version"
echo "   - docker-compose --version"