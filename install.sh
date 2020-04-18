#!/bin/sh
set -ex

if [ "$(id -u)" -eq 0 ]; then
  echo "Don't run this as root"
  exit
fi

sudo apt-get update
sudo apt-get install -y git bash curl wget

cd "$HOME"
git clone --recursive https://github.com/pierre-emmanuelJ/dotfiles
cd dotfiles

./run.sh
