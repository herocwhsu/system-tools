#!/bin/bash

# MASTER Installation Script for system-tools
# Supports both macOS and Linux (Ubuntu/Debian)

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dotfiles"
OLD_DOTFILES_DIR="$HOME/.dotfiles_old"
FILES="zshrc tmux.conf gitconfig vimrc editorconfig"

echo "🚀 Starting system-tools setup..."

# 1. Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
    echo "🍎 Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "🐧 Detected Linux"
else
    echo "⚠️ Unknown OS: $OSTYPE. Exiting."
    exit 1
fi

# 2. Backup existing dotfiles
echo "📦 Backing up old dotfiles to $OLD_DOTFILES_DIR"
mkdir -p "$OLD_DOTFILES_DIR"

for file in $FILES; do
    if [ -L "$HOME/.$file" ]; then
        rm "$HOME/.$file"
    elif [ -e "$HOME/.$file" ]; then
        mv "$HOME/.$file" "$OLD_DOTFILES_DIR/"
    fi
    
    # Create new symlink
    echo "🔗 Linking .$file"
    ln -s "$DOTFILES_DIR/$file" "$HOME/.$file"
done

# 3. Optimize System (Performance & Security)
optimize_system() {
    echo "⚡ Tuning system for server-like performance..."
    if [ "$OS" == "mac" ]; then
        # Mac Performance Tuning
        echo "🍎 Applying Mac optimizations..."
        # Increase File Limits
        sudo sysctl -w kern.maxfiles=524288 &>/dev/null
        sudo sysctl -w kern.maxfilesperproc=524288 &>/dev/null
        
        # Disable Sleep (Server Mode)
        sudo pmset -a sleep 0
        sudo pmset -a hibernatemode 0
        
        # Security: Enable Firewall
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on &>/dev/null
        
    elif [ "$OS" == "linux" ]; then
        # Linux Performance Tuning (requires root)
        echo "🐧 Applying Linux optimizations..."
        # Tune Swappiness (Use RAM more, Swap less)
        sudo sysctl -w vm.swappiness=10
        # Increase File Limits
        echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
        echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
    fi
}

# 4. OS-Specific Setup
if [ "$OS" == "mac" ]; then
    # Homebrew Setup
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "📦 Installing Mac packages from Brewfile..."
    brew bundle --file="$(dirname "${BASH_SOURCE[0]}")/mac/Brewfile"
    optimize_system

elif [ "$OS" == "linux" ]; then
    # Run your existing Linux setup script
    echo "📦 Running Linux setup script..."
    bash "$(dirname "${BASH_SOURCE[0]}")/linux/setup.sh"
    optimize_system
fi

echo "✅ system-tools installation complete!"
echo "🔄 Please restart your shell or run: source ~/.zshrc"
