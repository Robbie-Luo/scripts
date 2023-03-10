ZSH_ROOT="/home/lwt595403"
ZSH_PROXY=http://127.0.0.1:3128

export HOME=${ZSH_ROOT}
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8

function config_proxy() {
    local PROXY=$1
    export http_proxy=$PROXY
    export https_proxy=$PROXY
    export no_proxy="localhost,127.0.0.1,172.19.*,10.*,7.*,172.16.*,126.26.*,*.huawei.com"
}

function config_git() {
    git config --global user.name "l00595403"
    git config --global user.email "luoweitao@hisilicon.com"
    git config --global http.sslverify false
    git config --global http.proxy ${ZSH_PROXY}
    git config --global https.proxy ${ZSH_PROXY}
}

function config_omz() {
    export ZSH="${ZSH_ROOT}/.oh-my-zsh"
    if [ ! -d $ZSH ]; then
        mkdir -p $ZSH && git init --quiet "$ZSH" && cd $ZSH
        git config http.sslverify false
        git config http.proxy ${ZSH_PROXY}
        git config https.proxy ${ZSH_PROXY}
        git remote add origin "https://github.com/ohmyzsh/ohmyzsh.git"
        git pull origin master
        cd -
    fi

    AUTOSUGGESTION=$ZSH/custom/plugins/zsh-autosuggestions
    if [ ! -d $AUTOSUGGESTION ];then
        git clone https://github.com/zsh-users/zsh-autosuggestions $AUTOSUGGESTION
    fi

    ZSH_THEME="robbyrussell"
    plugins=(
        git
        zsh-autosuggestions
    )
    source $ZSH/oh-my-zsh.sh
}

function config_tmux()
{
    TQM="${ZSH_ROOT}/.tmux/plugins/tpm"
    if [ ! -d $TQM ];then
        git clone https://github.com/tmux-plugins/tpm $TQM
    fi

    if [ ! -f ${ZSH_ROOT}/.tmux.conf ];then
cat << EOF > ${ZSH_ROOT}/.tmux.conf
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'arcticicestudio/nord-tmux'
run '${ZSH_ROOT}/.tmux/plugins/tpm/tpm'
EOF
    tmux source ${ZSH_ROOT}/.tmux.conf
    fi
    tmux source ${ZSH_ROOT}/.tmux.conf
}

function install_requirement() {
    if command -v apt >/dev/null; then
        INTALL_CMD="apt install"
    elif command -v yum >/dev/null; then
        INTALL_CMD="yum install"
    fi
    command -v git >/dev/null || ${INTALL_CMD} git
    command -v zsh >/dev/null || ${INTALL_CMD} zsh
    command -v tmux >/dev/null || ${INTALL_CMD} tmux

    config_git
    config_omz
    config_tmux
}

function edit_zshrc()
{
    vim ${ZSH_ROOT}/.zshrc
    source ${ZSH_ROOT}/.zshrc
}

function config_alias() {
    # Tmux alias
    alias tn="tmux new -s"
    alias tl="tmux list-sessions"
    alias ta="tmux attach -t"
    alias tk="tmux kill-session -t"

    # Home alias
    alias h="cd ${ZSH_ROOT}"
    alias dl="cd ${ZSH_ROOT}/download/"
    alias src="cd ${ZSH_ROOT}/src"
    alias lib="cd ${ZSH_ROOT}/lib"
    alias repo="cd ${ZSH_ROOT}/repo"
    alias dev="cd ${ZSH_ROOT}/dev"

    alias kill_root="pkill -KILL -u root"
    alias drop_cache="sync && echo 3 > /proc/sys/vm/drop_caches"
    alias z='edit_zshrc'
}

config_proxy ${ZSH_PROXY}
install_requirement
config_alias
chpwd() ls

