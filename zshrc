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
export DOMAIN_NAME=my_example.com
export VSCODE_PASSWORD=my_example_password

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
vscode() {
	docker run \
            -d \
            --name "vscode" \
            -it \
            --rm \
            -u "$(id -u):$(id -g)" \
            --label "traefik.enable=true" \
            --label "traefik.http.routers.vscode.rule=Host(\`${DOMAIN_NAME}\`)" \
            --label "traefik.http.routers.vscode.entrypoints=websecure" \
            --label "traefik.http.routers.vscode.tls.certresolver=mydnschallenge" \
            --label "traefik.http.services.vscode.loadbalancer.server.port=8080" \
            --network traefik_default \
            -v "${PWD}:/home/coder/project" \
            -v "${HOME}/.local/share/code-server:/home/coder/.local/share/code-server"  \
            -v "${HOME}/.cache/code-server:/home/coder/.cache/code-server" \
            -e "GO111MODULE=${GO111MODULE}" \
            -e "PASSWORD=${VSCODE_PASSWORD}" \
            -v "${GOPATH}:/home/coder/go" \
            pierro777/vscode:3.5.0
}

alias code=vscode

alias rcode="docker stop vscode"

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

#NVM node version manager
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
