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
  python3
  python3-pip
  coreutils
  fuse
  s3fs
)

#User Creation
mkdir -p "$HOME/Downloads"
mkdir -p "$HOME/Documents"

function is_set() {
    local -n ref=$1

    if [ -z "$ref" ]
    then
        printf "%s:" "$2"
        read -r ref
    fi
}

is_set DOMAIN_NAME "Enter a domain name pointing on this machine"
is_set VSCODE_PASSWORD "Enter a password for VScode web"
is_set GO_VERSION "Enter Golang version"
is_set EXOSCALE_API_KEY "Enter Exoscale api key"
is_set EXOSCALE_SECRET_KEY "Enter Exoscale secret key"
is_set S3_ENDPOINT "Enter S3 custom endpoint"
is_set CLOUD_BUCKET_NAME "Enter an s3 bucket for your Cloud"
is_set GIT_NAME "Enter git config name"
is_set GIT_EMAIL "Enter git config email"

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

#Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

#Install podman
. /etc/os-release
sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt-get update -qq
sudo apt-get -qq -y install podman

#Install Golang
mkdir "$HOME/go"
wget -4 "https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"
GOPATH=/home/ubuntu/go
PATH=$PATH:/usr/local/go/bin:"$GOPATH"/bin

#Install kind
GO111MODULE="on" go get sigs.k8s.io/kind

#Install node
curl -4 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
nvm install 12.16 #(not used frequently) Can be added to input var

#install alias script
mkdir "$HOME/.bin"
$LN "$DOTFILES_FOLDER"/scripts/* "$HOME/.bin"

#Install VScode
cp -r "$DOTFILES_FOLDER/traefik" "$HOME"
touch "$HOME/traefik/acme.json" && \
        chmod 600 "$HOME/traefik/acme.json"
sed -i "s/example.com/$DOMAIN_NAME/g" "$HOME/traefik/traefik.toml"
cd "$HOME/traefik/" && sudo docker-compose up -d && cd -
mkdir -p "$HOME/.local/share/code-server/extensions"
chown -R ubuntu "$HOME/.local"

#GIT config
$LN "$DOTFILES_FOLDER/gitconfig" "$HOME/.gitconfig"
sed -i "s/name_example/$GIT_NAME/g" "$HOME/.gitconfig"
sed -i "s/email@example.com/$GIT_EMAIL/g" "$HOME/.gitconfig"

# Get our zshrc back
$LN "$DOTFILES_FOLDER/zshrc" "$HOME/.zshrc"
sed -i "s/my_example.com/$DOMAIN_NAME/g" "$HOME/.zshrc"
sed -i "s/my_example_password/$VSCODE_PASSWORD/g" "$HOME/.zshrc"


#Exoscale
sudo snap install exoscale-cli

#S3FS Cloud
mkdir "$HOME/Cloud"
mkdir "$HOME/.aws"

echo "[default]" > "${HOME}/.aws/credentials"
echo "aws_access_key_id = $EXOSCALE_API_KEY" >> "${HOME}/.aws/credentials"
echo "aws_secret_access_key = $EXOSCALE_SECRET_KEY" >> "${HOME}/.aws/credentials"


echo "$EXOSCALE_API_KEY:$EXOSCALE_SECRET_KEY" > "$HOME/.passwd-s3fs"
chmod 600 "$HOME/.passwd-s3fs"

s3fs -o url="$S3_ENDPOINT" "$CLOUD_BUCKET_NAME:/" "$HOME/Cloud"

echo "run: source ~/.zshrc"
