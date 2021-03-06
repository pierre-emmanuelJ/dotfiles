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
  openjdk-11-jdk
  rlwrap
  leiningen
  jq
  detox
  rename
  zsh
  vim
  python3
  coreutils
  fuse
  s3fs
  direnv
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
is_set GOOFYS_VERSION "Enter goofys version (v0.24.0)"
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
mkdir -p "$HOME/go"
wget -4 "https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"
GOPATH=/home/ubuntu/go
PATH=$PATH:/usr/local/go/bin:"$GOPATH"/bin

#Install kind
GO111MODULE="on" go get sigs.k8s.io/kind

#Install node
curl -4 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install 12.16 #(not used frequently) Can be added to input var

#install alias script
mkdir -p "$HOME/.bin"
$LN "$DOTFILES_FOLDER"/scripts/* "$HOME/.bin"

#Install VScode
mkdir "$HOME/traefik"
$LN "$DOTFILES_FOLDER"/traefik/* "$HOME/traefik"
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
mkdir -p "$HOME/Cloud"
mkdir -p "$HOME/.aws"

echo "[default]" > "${HOME}/.aws/credentials"
echo "aws_access_key_id = $EXOSCALE_API_KEY" >> "${HOME}/.aws/credentials"
echo "aws_secret_access_key = $EXOSCALE_SECRET_KEY" >> "${HOME}/.aws/credentials"


echo "$EXOSCALE_API_KEY:$EXOSCALE_SECRET_KEY" > "$HOME/.passwd-s3fs"
chmod 600 "$HOME/.passwd-s3fs"

wget -4 "https://github.com/kahing/goofys/releases/download/$GOOFYS_VERSION/goofys"
chmod +x goofys && sudo mv goofys /usr/local/bin

#goofys --file-mode=0666 --dir-mode=0777 --endpoint "https://sos-ch-dk-2.exo.io" cloud  "$HOME/Cloud"

s3fs -o url="$S3_ENDPOINT" "$CLOUD_BUCKET_NAME:/" "$HOME/Cloud"

#Shellcheck
SHELLCHECK_VERSION=v0.7.1
wget https://github.com/koalaman/shellcheck/releases/download/$SHELLCHECK_VERSION/shellcheck-$SHELLCHECK_VERSION.linux.x86_64.tar.xz
tar -xvf shellcheck-$SHELLCHECK_VERSION.linux.x86_64.tar.xz
cd shellcheck-$SHELLCHECK_VERSION && mv shellcheck /usr/local/bin/ && cd ..

#Clojure
CLJ_VERSION=1.10.1.763
curl -O https://download.clojure.org/install/linux-install-$CLJ_VERSION.sh
chmod +x linux-install-$CLJ_VERSION.sh
sudo ./linux-install-$CLJ_VERSION.sh
rm -f ./linux-install-$CLJ_VERSION.sh

echo "run: source ~/.zshrc"
