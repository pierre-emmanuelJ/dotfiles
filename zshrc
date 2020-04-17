echo -e "\033[38;5;160m    ╱▙\n \
  ╱╱█▙\033[0m \033[1mE X O S C A L E\033[0m \
\033[38;5;160m\n  ╱╱╱██▙\033[0m\n \
 This is a private system operated from and by \033[1mExoscale\033[0m.\n \
 Use by unauthorized persons is prohibited.\033[0m"

# Path to your oh-my-zsh installation.
export ZSH="/home/ubuntu/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    kubectl
    docker
)

source $ZSH/oh-my-zsh.sh

# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export GPG_TTY=/dev/pts/0s

#Alias
alias k=kubectl

#Script cmds
export PATH=$PATH:$HOME/.bin

## cd git repo root directory
alias repo_root='git rev-parse --show-toplevel'
alias rr='cd $(repo_root)'
function todo {
    local query
    if [ "$1" = "" ]
    then
        query="TODO"
    else
        query="TODO($1)"
    fi
    grep -rn -I "$query" \
        --exclude-dir "vendor" \
        --exclude-dir "node_modules" \
        --ex
}

# Exoscale
export EXOSCALE_COMPUTE_ENDPOINT=https://api.exoscale.com/compute

##GOLANG
export GOPATH=/home/ubuntu/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export GO111MODULE=off

#Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


#VScode web
alias clean-workspace="rm -rf $HOME/.local/share/code-server/Workspaces/*"
alias code="docker run \
            -d \
            --name vscode \
            --rm  \
            -it \
            --label traefik.frontend.rule=Host:${DOMAIN_NAME}  \
            --label traefik.enable=true \
            --network traefik_default \
            -v "${PWD}:/home/coder/project" \
            -v "${HOME}/.local/share/code-server:/home/coder/.local/share/code-server"  \
            -v "${HOME}/.cache/code-server:/home/coder/.cache/code-server" \
            -e ${GO111MODULE} \
	        -e "PASSWORD=${VSCODE_PASSWORD}" \
            -v ${GOPATH}:/home/coder/go \
            pierro777/vscode:2.1692-vsc1.39.2 \
            --allow-http"

alias rcode="docker stop vscode"

#Install podman
. /etc/os-release
sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt-get update -qq
sudo apt-get -qq -y install podman

#Fedora CoreOS Dev
cosa() {
   env | grep COREOS_ASSEMBLER
   set -x
   podman run --rm -ti --security-opt label=disable --privileged                                    \
              --uidmap=1000:0:1 --uidmap=0:1:1000 --uidmap 1001:1001:64536                          \
              -v ${PWD}:/srv/ --device /dev/kvm --device /dev/fuse                                  \
              --tmpfs /tmp -v /var/tmp:/var/tmp --name cosa                                         \
              ${COREOS_ASSEMBLER_CONFIG_GIT:+-v $COREOS_ASSEMBLER_CONFIG_GIT:/srv/src/config/:ro}   \
              ${COREOS_ASSEMBLER_GIT:+-v $COREOS_ASSEMBLER_GIT/src/:/usr/lib/coreos-assembler/:ro}  \
              ${COREOS_ASSEMBLER_CONTAINER_RUNTIME_ARGS}                                            \
              ${COREOS_ASSEMBLER_CONTAINER:-quay.io/coreos-assembler/coreos-assembler:latest} "$@"
   
   rc=$?; set +x; return $rc
}