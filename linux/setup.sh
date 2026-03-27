#!/bin/bash
set -e

echo "🔧 開始安裝常用套件與開發工具..."

# 更新系統
sudo apt update && sudo apt upgrade -y

# 安裝常用工具
sudo apt install -y \
  git curl wget unzip build-essential \
  htop iftop bmon glances net-tools \
  ca-certificates gnupg lsb-release

# 安裝 Docker & docker-compose
echo "🐳 安裝 Docker..."
sudo apt install -y apt-transport-https ca-certificates software-properties-common
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# 安裝 Zsh 與 Oh My Zsh
echo "💻 安裝 Zsh..."
sudo apt install -y zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 安裝 Zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 更新 .zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# 安裝中文支援與輸入法
echo "🌐 安裝中文語言與輸入法..."
sudo apt install -y language-pack-zh-hant fonts-noto-cjk fcitx5 fcitx5-mozc
im-config -n fcitx5

echo "✅ 完成安裝！請重新登入以套用 Docker 權限與 Zsh 預設 shell。"

