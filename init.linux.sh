#!/usr/bin/env bash

set -u

INIT_PATH=$(cd $(dirname $0) && pwd)
INSTALL_DOCKER=0

help() {
  cat << EOF
usage: $0 [OPTIONS]
    --help               Show this message
    --all                Install all tools auto
    --docker             Install docker auto
EOF
}

for opt in "$@"; do
  case $opt in
    --help)
      help
      exit 0
      ;;
    --all)
      INSTALL_DOCKER=1
      ;;
    --docker)
      INSTALL_DOCKER=1
      ;;
    *)
      echo "unknown option: $opt"
      help
      exit 1
      ;;
  esac
done

if [[ -e /etc/debian_version ]]; then
  OS=debian
  INSTALLER=apt
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
  OS=centos
  INSTALLER=yum
else
  echo "Looks like you aren't running this installer on Debian, Ubuntu or CentOS"
  exit
fi

echo '
---------------------------------------------
-------------- package update ---------------
---------------------------------------------
'

$INSTALLER update -y

echo '
---------------------------------------------
-------------------- curl -------------------
---------------------------------------------
'

if !(which curl >/dev/null 2>&1); then
  $INSTALLER install -y curl
fi

echo '
---------------------------------------------
-------------------- zsh --------------------
---------------------------------------------
'

if !(which zsh >/dev/null 2>&1); then
  $INSTALLER install -y zsh
fi

echo '
---------------------------------------------
-------------------- git --------------------
---------------------------------------------
'

if !(which git >/dev/null 2>&1); then
  $INSTALLER install -y git
fi

echo '
---------------------------------------------
-------------------- tmux -------------------
---------------------------------------------
'

if !(which tmux >/dev/null 2>&1); then
  $INSTALLER install -y tmux
fi

if [ ! -e "$HOME/.tmux.conf" ]; then
  ln -sf "$INIT_PATH/tmux.conf" "$HOME/.tmux.conf"
fi

echo '
---------------------------------------------
----------------- oh-my-zsh -----------------
---------------------------------------------
'

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && bash
fi

if [ ! -e "$HOME/.localrc" ]; then
  cp "$INIT_PATH/localrc.zsh" "$HOME/.localrc"
  echo "[ -f \$HOME/.localrc ] && . \$HOME/.localrc" >> "$HOME/.zshrc"
  zsh "$HOME/.zshrc"
fi

echo '
---------------------------------------------
-------------------- fzf --------------------
---------------------------------------------
'

if !(which fzf >/dev/null 2>&1); then
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install --all
  zsh "$HOME/.zshrc"
fi

echo '
---------------------------------------------
-------------------- htop -------------------
---------------------------------------------
'

if !(which htop >/dev/null 2>&1); then
  $INSTALLER install -y htop
fi

echo '
---------------------------------------------
------------------- docker ------------------
---------------------------------------------
'

if [ $INSTALL_DOCKER -eq 1 ]; then
  if !(which docker >/dev/null 2>&1); then
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
  fi

  if !(which docker-compose >/dev/null 2>&1); then
    sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi
fi

echo '
---------------------------------------------
------------------ all done -----------------
---------------------------------------------
'
