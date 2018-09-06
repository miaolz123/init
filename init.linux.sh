#!/bin/bash

INITPATH=$(
  cd $(dirname $0)
  pwd
)

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

$INSTALLER update

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
  ln -sf "$INITPATH/tmux.conf" "$HOME/.tmux.conf"
fi

echo '
---------------------------------------------
----------------- oh-my-zsh -----------------
---------------------------------------------
'

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

if [ ! -e "$HOME/.localrc" ]; then
  cp "$INITPATH/localrc.zsh" "$HOME/.localrc"
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
------------------- docker ------------------
---------------------------------------------
'

if !(which docker >/dev/null 2>&1); then
  curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
fi

if !(which docker-compose >/dev/null 2>&1); then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

echo '
---------------------------------------------
------------------ all done -----------------
---------------------------------------------
'
