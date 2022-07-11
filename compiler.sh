#!/bin/bash
set -e
function update_path()
{
    echo "$1" >> $INST_DIR/.profile 
    export PATH="$1/bin:$PATH"
    export LD_LIBRARY_PATH="$1/lib:$LD_LIBRARY_PATH"
    export CMAKE_PREFIX_PATH="$1:$CMAKE_PREFIX_PATH"
}

function prepare_build()
{
    SRC=$LIB_DIR/$1
    VERSION=$2
    if [ ! -d $SRC ];then
        git clone --recursive $3 $SRC
    fi
    cd $SRC
    git checkout $VERSION
    if [ ! -d build ];then
        mkdir build
    fi
    cd build
    rm -rf *
}

function compile()
{
    prepare_build $1 $2 $3
    PREFIX=$INST_DIR/$1/$2
    cmake_d="$4"
    cmake_d="$cmake_d -DCMAKE_BUILD_TYPE=Release"
    cmake_d="$cmake_d -DCMAKE_INSTALL_PREFIX=$PREFIX"
    cmake_d="$cmake_d -D CMAKE_CXX_FLAGS='-fPIC'"
    cmake .. -G "Ninja" $cmake_d
    ninja install    
    update_path $PREFIX
}

function compile_release()
{
    SRC=$LIB_DIR/$1
    VERSION=$2
    TYPE=$(echo $BUILD_TYPE | tr '[:upper:]' '[:lower:]')
    PREFIX=$INST_DIR/$1/$2/$TYPE
    if [ ! -d $SRC ];then
        git clone --recursive $3 $SRC
    fi
    cd $SRC
    git checkout $VERSION
    if [ ! -d build-$TYPE ];then
        mkdir build-$TYPE
    fi
    cd build-$TYPE
    cmake_d="$4"
    cmake_d="$cmake_d -DCMAKE_BUILD_TYPE=Release"
    cmake_d="$cmake_d -DCMAKE_INSTALL_PREFIX=$PREFIX"
    cmake_d="$cmake_d -D CMAKE_CXX_FLAGS='-fPIC'"
    cmake .. -G "Ninja" $cmake_d
    ninja install    
    update_path $PREFIX
}

function compile_deps()
{
    prepare_build $1 $2 $3
    PREFIX=$INST_DIR/deps
    cmake_d="$4"
    cmake_d="$cmake_d -DCMAKE_BUILD_TYPE=Release"
    cmake_d="$cmake_d -DCMAKE_INSTALL_PREFIX=$PREFIX"
    cmake .. -G "Ninja" $cmake_d
    ninja install    
}

function compile_py()
{
    prepare_build $1 $2 $3
    PREFIX=$INST_DIR/$1/$2
    update_path $PREFIX
    if [ ! -d $PREFIX ];then
        ../configure --prefix=$PREFIX --with-ensurepip=install --enable-optimizations --enable-ipv6 --enable-loadable-sqlite-extensions --with-dbmliborder=bdb --with-computed-gotos --with-pymalloc --enable-shared
        make install -j
        $PREFIX/bin/python3 -m pip install numpy certifi requests cython zstandard idna
    fi
    #$PREFIX/bin/python3 -m pip install numpy certifi requests cython zstandard idna
}

function compile_boost()
{
    prepare_build $1 boost-$2 $3
    PREFIX=$INST_DIR/$1/$2
    update_path $PREFIX
    if [ ! -d $PREFIX ];then
        ../bootstrap.sh --with-python-root=$INST_DIR/python/$PYTHON_VERSION --with-python-version=3.10 
        cd ..
        build/b2 -j96 --prefix=$PREFIX --with-system --with-filesystem --with-thread --with-regex --with-locale --with-date_time --with-wave --with-iostreams --with-python --with-program_options --with-serialization --with-atomic  install 
    fi
}

function compile_llvm()
{
    prepare_build $1 llvmorg-$2 $3
    PREFIX=$INST_DIR/llvm/$2
    update_path $PREFIX
    cmake_d="$cmake_d -DCMAKE_BUILD_TYPE=Release"
    cmake_d="$cmake_d -DCMAKE_INSTALL_PREFIX=$PREFIX"
    cmake_d="$cmake_d -DLLVM_BUILD_LLVM_DYLIB=ON"
    cmake_d="$cmake_d -DLLVM_ENABLE_RTTI=ON"
    cmake ../llvm -G "Ninja" $cmake_d
    ninja install    
}

function compile_FFmpeg()
{
    SRC=$LIB_DIR/FFmpeg
    VERSION=$FFMPEG_VERSION
    PREFIX=$INST_DIR/FFmpeg/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/FFmpeg/FFmpeg.git $SRC
    fi
    cd $SRC
    if [ ! -d $PREFIX ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        ../configure --prefix=$PREFIX\
        --enable-ffplay --enable-shared --enable-gpl \
        --enable-libx264 --enable-libx265 --enable-libvpx
        make install -j
    fi
    update_path $PREFIX
}