#!/bin/bash

# MASTER Installation Script for system-tools
# Supports both macOS (Zsh) and Linux (Bash/Zsh)

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dotfiles"
OLD_DOTFILES_DIR="$HOME/.dotfiles_old"
FILES="zshrc bashrc tmux.conf gitconfig vimrc editorconfig"

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
    # Link name in home directory (needs the dot)
    link_name="$HOME/.$file"
    
    if [ -L "$link_name" ]; then
        rm "$link_name"
    elif [ -e "$link_name" ]; then
        mv "$link_name" "$OLD_DOTFILES_DIR/"
    fi
    
    # Create new symlink
    echo "🔗 Linking .$file"
    ln -s "$DOTFILES_DIR/$file" "$link_name"
done

# 3. Optimize System (Performance & Security)
optimize_system() {
    echo "⚡ Tuning system for server-like performance..."
    if [ "$OS" == "mac" ]; then
        echo "🍎 Applying Mac optimizations..."
        sudo sysctl -w kern.maxfiles=524288 &>/dev/null
        sudo sysctl -w kern.maxfilesperproc=524288 &>/dev/null
        sudo pmset -a sleep 0
        sudo pmset -a hibernatemode 0
        sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on &>/dev/null
    elif [ "$OS" == "linux" ]; then
        echo "🐧 Applying Linux optimizations..."
        sudo sysctl -w vm.swappiness=10
        echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
        echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
    fi
}

# 4. OS-Specific Setup
if [ "$OS" == "mac" ]; then
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "📦 Installing Mac packages from Brewfile..."
    brew bundle --file="$(dirname "${BASH_SOURCE[0]}")/mac/Brewfile"
    optimize_system

elif [ "$OS" == "linux" ]; then
    echo "📦 Running Linux setup script..."
    bash "$(dirname "${BASH_SOURCE[0]}")/linux/setup.sh"
    optimize_system
fi

echo "✅ system-tools installation complete!"
echo "🔄 Please restart your shell (source ~/.zshrc or source ~/.bashrc)"
