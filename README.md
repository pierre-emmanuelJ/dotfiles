# Dotefiles

Dotfiles for Ubuntu >= 16.04 LTS

## Install Interactive

```
curl -sSL -o install.sh https://raw.githubusercontent.com/pierre-emmanuelJ/dotfiles/master/install.sh \
          && chmod +x install.sh \
          && ./install.sh \
          && rm install.sh
```


## Install Auto

```
curl -sSL https://raw.githubusercontent.com/pierre-emmanuelJ/dotfiles/master/install.sh | \
          DOMAIN_NAME=example.com \
          VSCODE_PASSWORD=my_password \
          GO_VERSION=1.14.2 \
          EXOSCALE_API_KEY=EXO.... \
          EXOSCALE_SECRET_KEY=XXXXXX \
          S3_ENDPOINT="https://sos-ch-dk-2.exo.io" \
          CLOUD_BUCKET_NAME=cloud \
          GOOFYS_VERSION=v0.24.0 \
          GIT_NAME="Pierre-Emmanuel Jacquier" \
          GIT_EMAIL="15922119+pierre-emmanuelJ@users.noreply.github.com" \
          sh
```
