#!/bin/bash
set -ex

DOTFILES_FOLDER="$(dirname "$(realpath "$0")")"
LN="ln -sf"

sudo DEBIAN_FRONTEND=noninteractive \
       LANGUAGE=en_US.UTF-8 \
       LANG=en_US.UTF-8 \
       LC_ALL=en_US.UTF-8 \
       dpkg-reconfigure locales

PACKAGES=(
  git
  curl wget
  vim
  rsync
  htop
  zip unzip
  gzip tar
  tmux
  httpie
  tree
  links
  shellcheck
  jq
  detox
  rename
  zsh
  vim
  python-pip
)

if [ -x "$(command -v apt-get)" ]; then
  echo "Installing packages"
  sudo apt-get install -y "${PACKAGES[@]}"
else
  echo "Can't install packages without apt"
  sleep 3
fi

# Set zsh default shell
sudo chsh "$USER" -s "$(which zsh)"

# Avoid breaking the oh-my-zsh install script
rm -rf "$HOME/.zshrc"
export SHELL
SHELL="$(which zsh)"

echo "Installing oh-my-zsh"
wget -4 -qO- "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh" | sh

#Install docker
curl -4 -sSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

printf "Enter Golang version:"
read -r GO_VERSION

#Install Golang
mkdir "$HOME/go"
wget -4 "https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"

#Install node
curl -4 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

#install alias script
mkdir "$HOME/.bin"
cp "$DOTFILES_FOLDER"/scripts/* "$HOME/.bin"

#Install VScode
printf "Enter a domain name pointing on this machine:"
read -r DOMAIN_NAME
printf "Enter a password for VScode web:"
read -r VSCODE_PASSWORD
cp -r "$DOTFILES_FOLDER/traefik" "$HOME"
touch "$HOME/traefik/acme.json" && \
        chmod 600 "$HOME/traefik/acme.json"
sed "s/example.com/$DOMAIN_NAME/g" "$HOME/traefik/traefik.toml"
cd "$HOME/traefik/" && sudo docker-compose up -d && cd -

# Get our zshrc back
$LN "$DOTFILES_FOLDER/zshrc" "$HOME/.zshrc"
echo export DOMAIN_NAME="$DOMAIN_NAME" >> "$HOME/.zshrc"
echo export VSCODE_PASSWORD="$VSCODE_PASSWORD" >> "$HOME/.zshrc"


#Exoscale
sudo snap install exoscale-cli
exo config

echo "run: source ~/.zshrc"