export ZSH="/root/.oh-my-zsh"
export TERM=xterm-256color

ZSH_THEME="robbyrussell"
plugins=(
    git
    zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

function add_to_path()
{
    echo "$1" >> $INST_DIR/.profile 
    export PATH="$1/bin:$PATH"
    export LD_LIBRARY_PATH="$1/lib:$LD_LIBRARY_PATH"
    export CMAKE_PREFIX_PATH="$1:$CMAKE_PREFIX_PATH"
}

for i in $(cat /opt/.profile)
do
    add_to_path $i
done

# Tmux alias
alias tn="tmux new -s"
alias tl="tmux list-sessions"
alias ta="tmux attach -t"
alias tk="tmux kill-session -t"

# shortcuts
alias ldso="cd /etc/ld.so.conf.d"
alias show="ps -ef |grep"
alias size="du -h -d 1 *"

# systemctl alias
alias s_status="systemctl status"
alias s_restart="systemctl restart"
alias s_stop="systemctl stop"
alias s_reload="systemctl daemon-reload"

# Home alias
HOME_DIR="/home/lwt595403"
alias h="cd $HOME_DIR"
alias dl="cd $HOME_DIR/download/"
alias src="cd $HOME_DIR/src"
alias lib="cd $HOME_DIR/lib"
alias repo="cd $HOME_DIR/repo"
alias dev="cd $HOME_DIR/dev"
alias run="cd $HOME_DIR/run"



# Proxy
function set_proxy()
{
    PROXY=http://127.0.0.1:3128
    export http_proxy=$PROXY
    export https_proxy=$PROXY
    export no_proxy="localhost,127.0.0.1,172.19.*,10.*,7.*,172.16.*,126.26.*,*.huawei.com"
#    git config --global http.proxy $PROXY
#    git config --global https.proxy $PROXY
}
set_proxy
# DISPLAY
function set_display()
{
    systemctl start xrdp
    export DISPLAY=$(ps -ef |grep Xorg | head -n 1|awk '{print $9}')
    glxinfo -B |head -n 10|tail -n 6
}

function drop_cache()
{
    sync
    echo 3 > /proc/sys/vm/drop_caches
    swapoff -a
    swapon -a
    printf '\n%s\n' 'Ram-cache and Swap Cleared'
}

function kill_root()
{
    pkill -KILL -u root
    systemctl restart xrdp
    systemctl restart smbd
}

function edit_zshrc()
{
    vim ~/.zshrc
    source ~/.zshrc
}
alias z='edit_zshrc'

function edit_profile()
{
    vim /opt/profile
    source ~/.zshrc
}
alias x='edit_profile'

chpwd() ls 

if [ -d ~/thinclient_drives ]; then
    umount thinclient_drives
    rm -rf thinclient_drives
fi
