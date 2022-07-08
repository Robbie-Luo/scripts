export ZSH="/root/.oh-my-zsh"
export TERM=xterm-256color

ZSH_THEME="robbyrussell"
plugins=(
    git
    zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

# Path
LIST="
/env/base/bin
/opt/install/mono/bin
/opt/install/python/3.10.5/bin
/opt/install/cmake/3.22.1/bin
/opt/install/ispc/1.18.0/bin
/opt/install/llvm/14.0.6/bin
/usr/local/sbin
/usr/local/bin
/usr/sbin
/usr/bin
/bin
"
export PATH=$(echo $LIST | sed '1d' | sed '$d' | tr '\n' ':')
unset LIST

# LD_LIBRARY_PATH
LIST="
/opt/install/alembic/1.7.16/lib
/opt/install/osd/3.4.4/lib
/opt/install/osl/1.11.17/lib
/opt/install/oiio/2.3.16/lib
/opt/install/ocio/2.1.2/lib
/opt/install/opencollada/1.6.68/lib
/opt/install/openvdb/9.1.0/lib
/opt/install/openexr/2.5.8/lib
/opt/install/openxr/1.0.24/lib
/opt/install/Imath/3.1.5/lib
/opt/install/python/3.10.5/lib
/opt/install/boost/1.78.0/lib
/opt/install/llvm/14.0.6/lib
/opt/install/kplblas/lib
/opt/install/mono/lib
/opt/deps/lib
/usr/local/lib/aarch64-linux-gnu
/usr/lib/aarch64-linux-gnu
/lib/aarch64-linux-gnu
"
export LD_LIBRARY_PATH=$(echo $LIST | sed '1d' | sed '$d' | tr '\n' ':')
unset LIST

# CMAKE_PREFIX_PATH
LIST="
/opt/install/alembic/1.7.16
/opt/install/osd/3.4.4
/opt/install/osl/1.11.17
/opt/install/oiio/2.3.16
/opt/install/ocio/2.1.2
/opt/install/opencollada/1.6.68
/opt/install/openvdb/9.1.0
/opt/install/openexr/2.5.8
/opt/install/openxr/1.0.24
/opt/install/Imath/3.1.5
/opt/install/python/3.10.5
/opt/install/boost/1.78.0
/opt/install/llvm/14.0.6
/opt/install/kplblas
/opt/deps
"
export CMAKE_PREFIX_PATH=$(echo $LIST | sed '1d' | sed '$d' | tr '\n' ':')
unset LIST

#PKG_CONFIG
LIST="
/opt/install/python/3.10.5/lib/pkgconfig
"
export PKG_CONFIG_PATH=$(echo $LIST | sed '1d' | sed '$d' | tr '\n' ':')
unset LIST

source /opt/profile

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
