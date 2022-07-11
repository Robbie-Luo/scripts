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
    if [ "$FORCE_REBUILD" = true ];then
        rm -rf *
    fi
}

function compile_ispc()
{
    prepare_build ispc v1.18.0 https://github.com/ispc/ispc.git
    prepare_build llvm-ispc llvmorg-13.0.1 https://github.com/llvm/llvm-project.git 

    PREFIX=$INST_DIR/llvm-ispc/13.0.1
    cd $LIB_DIR/llvm-ispc
    for patch in $(ls $LIB_DIR/ispc/llvm_patches | grep 13_0)
    do 
        git apply $LIB_DIR/ispc/llvm_patches/$patch
        git status
    done
    cd $LIB_DIR/llvm-ispc/build
    cmake  -G "Ninja" -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;openmp" -DLLVM_ENABLE_DUMP=ON -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_INSTALL_UTILS=ON  -DLLVM_TARGETS_TO_BUILD=AArch64\;ARM\;X86  -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly  ../llvm
    ninja install
    update_path $PREFIX

    PREFIX=$INST_DIR/ispc/v1.18.0
    cd $LIB_DIR/ispc/build
    cmake  -G "Ninja" .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX
    ninja install
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

function compile_oidn()
{
    if [ $(uname -m) == "aarch64" ]; then
        prepare_build openblas v0.3.20 https://github.com/xianyi/OpenBLAS.git
        BLAS_PREFIX=$INST_DIR/openblas/v0.3.20
        cmake  -G "Ninja" .. -DCMAKE_INSTALL_PREFIX=$BLAS_PREFIX -DCMAKE_BUILD_TYPE=Release -DUSE_OPENMP=1 -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF
        ninja install
    fi
    prepare_build oidn master https://github.com/Robbie-Luo/oidn-aarch64.gi
    PREFIX=$INST_DIR/oidn/v1.4.3
    if [ $(uname -m) == "aarch64" ]; then
        cmake_d="-DCMAKE_BUILD_TYPE=Release"
        cmake_d="$cmake_d -DCMAKE_INSTALL_PREFIX=$PREFIX"
        cmake_d="$cmake_d -DDNNL_BLAS_VENDOR=OPENBLAS"
        cmake_d="$cmake_d -DBLAS_INCLUDE_DIR=$BLAS_PREFIX/include/openblas"
        cmake  -G "Ninja" .. $cmake_d
    else 
        cmake  -G "Ninja" .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX
    fi
    ninja install
}


set -e
LIB_DIR="/home/lwt595403/lib"
INST_DIR="/opt"
BUILD_TYPE="Release"
FORCE_REBUILD="false"

compile_ispc