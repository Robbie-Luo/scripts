#!/bin/bash
set -e
HOME_DIR=/root
CURR_DIR=$(pwd)
apt install zsh tmux

#tmux
PREFIX="$HOME_DIR/.tmux/plugins/tpm"
if [ ! -d $PREFIX ];then
    git clone https://github.com/tmux-plugins/tpm $PREFIX
fi
echo "set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'arcticicestudio/nord-tmux'
run '$HOME_DIR/.tmux/plugins/tpm/tpm'" > $HOME_DIR/.tmux.conf

