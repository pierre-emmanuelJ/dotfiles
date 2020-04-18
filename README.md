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
          sh
```
