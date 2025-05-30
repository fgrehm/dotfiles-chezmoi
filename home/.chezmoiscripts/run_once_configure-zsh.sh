#!/bin/bash

if $(grep $USER /etc/passwd | grep -v -q zsh); then
  sudo usermod -s /bin/zsh "${USER}"
fi

if ! [[ -d "${HOME}/.oh-my-zsh" ]]; then
  # https://github.com/ohmyzsh/ohmyzsh#unattended-install
  sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended
fi
