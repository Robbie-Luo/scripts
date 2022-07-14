#!/bin/bash
set -e
CURR_DIR=$(pwd)
apt install zsh tmux

# oh-my-zsh
PREFIX="~/.oh-my-zsh"
#rm -rf $PREFIX
if [ ! -d $PREFIX ];then
  git clone https://github.com/ohmyzsh/ohmyzsh.git $PREFIX
  cp $CURR_DIR/.zshrc ~
  chsh -s $(which zsh)
  cp $CURR_DIR/.zshrc ~
fi

PREFIX="~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
if [ ! -d $PREFIX ];then
	git clone https://github.com/zsh-users/zsh-autosuggestions $PREFIX 
fi

#tmux
PREFIX="~/.tmux/plugins/tpm"
if [ ! -d $PREFIX ];then
	git clone https://github.com/tmux-plugins/tpm $PREFIX
fi
echo "set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'arcticicestudio/nord-tmux'
run '~/.tmux/plugins/tpm/tpm'" > ~/.tmux.conf 

#gnome-nord
PREFIX=~/.themes/nord-gnome-terminal
if [ ! -d $PREFIX ];then
    git clone https://github.com/arcticicestudio/nord-gnome-terminal.git $PREFIX
    cd $PREFIX/src
    ./nord.sh
fi

#nordic
PREFIX=~/.themes/Nordic
if [ ! -d $PREFIX ];then
    git clone https://github.com/EliverLara/Nordic.git $PREFIX
fi
gsettings set org.gnome.desktop.interface gtk-theme "Nordic"
gsettings set org.gnome.desktop.wm.preferences theme "Nordic"


PREFIX=~/.themes/Tela-icon-theme
if [ ! -d $PREFIX ];then
    git clone https://github.com/vinceliuice/Tela-icon-theme.git $PREFIX
    cd $PREFIX
    ./install.sh -a
fi

#vimplus
PREFIX=~/.vimplus
if [ ! -d $PREFIX ];then
    git clone https://github.com/chxuan/vimplus.git $PREFIX
    cd $PREFIX
    ./install.sh
    echo "Plug 'arcticicestudio/nord-vim'" > ~/.vimrc.custom.plugins
    vim -c "PlugInstall" -c "q" -c "q"
    sed -i "s/onedark/nord/g" ~/.vimrc
    git clone https://github.com/ycm-core/YouCompleteMe.git
    cd YouCompleteMe/
    git submodule update --init --recursive
    ./install.py --all
fi
