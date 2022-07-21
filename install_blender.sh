#!/bin/bash
set -e
LIB_DIR="/home/lwt595403/lib"
INST_DIR="/opt/blender3.2"
BUILD_TYPE="Release"
FORCE_REBUILD="false"

if [ ! -d $INST_DIR ];then
    mkdir $INST_DIR
    echo "$INST_DIR" > $INST_DIR/.profile
fi

export PATH="$INST_DIR/deps/bin:$PATH"
export LD_LIBRARY_PATH="$INST_DIR/deps/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$INST_DIR/deps:$CMAKE_PREFIX_PATH"

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
    PREFIX=$INST_DIR/deps
    if [ ! -f $PREFIX/bin/python3 ];then
        ../configure --prefix=$PREFIX --with-ensurepip=install --enable-optimizations --enable-ipv6 --enable-loadable-sqlite-extensions --with-dbmliborder=bdb --with-computed-gotos --with-pymalloc --enable-shared
        make install -j
        $PREFIX/bin/python3 -m pip install numpy certifi requests cython zstandard idna
    fi
}

function compile_boost()
{
    prepare_build $1 boost-$2 $3
    PREFIX=$INST_DIR/deps
    if [ ! -d $PREFIX/include/boost ];then
        ../bootstrap.sh --with-python-root=$INST_DIR/python/v3.10.5 --with-python-version=3.10 
        cd ..
        build/b2 -j96 --prefix=$PREFIX --with-system --with-filesystem --with-thread --with-regex --with-locale --with-date_time --with-wave --with-iostreams --with-python --with-program_options --with-serialization --with-atomic  install 
    fi
}

function compile_blender()
{
    prepare_build $1 $2 $3
    PREFIX=$INST_DIR/
    cmake_d="$4"
    cmake_d="$cmake_d -DCMAKE_BUILD_TYPE=Release"
    cmake_d="$cmake_d -DCMAKE_INSTALL_PREFIX=$PREFIX"
    cmake .. -G "Ninja" $cmake_d
    ninja install    
}

apt build-dep libopenimageio-dev libglfw3-dev
apt install -y libpugixml-dev libpcre3-dev libxml2-dev libavdevice-dev llvm-12-dev libclang-12-dev\
             gawk cmake cmake-curses-gui build-essential libjpeg-dev libpng-dev libtiff-dev \
             git libfreetype6-dev libfontconfig-dev libx11-dev flex bison libxxf86vm-dev \
             libxcursor-dev libxi-dev wget libsqlite3-dev libxrandr-dev libxinerama-dev \
             libwayland-dev wayland-protocols libegl-dev libxkbcommon-dev libdbus-1-dev linux-libc-dev \
             libbz2-dev libncurses5-dev libssl-dev liblzma-dev libreadline-dev \
             libopenal-dev libglew-dev libglfw3-dev yasm \
             libsdl2-dev libfftw3-dev patch bzip2 libxml2-dev libtinyxml-dev libjemalloc-dev \
             libgmp-dev libpugixml-dev libpotrace-dev libhpdf-dev libzstd-dev

compile_deps oneTBB v2021.5.0 https://github.com/oneapi-src/oneTBB.git 
compile_py python v3.10.5 https://github.com/python/cpython.git
compile_boost boost 1.78.0 https://github.com/boostorg/boost.git
compile_deps ptex v2.4.1 https://github.com/wdas/ptex.git
compile_deps libjpeg-turbo 2.1.3 https://github.com/libjpeg-turbo/libjpeg-turbo.git
compile_deps libheif v1.12.0 https://github.com/strukturag/libheif.git
compile_deps Imath v3.1.5 https://github.com/AcademySoftwareFoundation/Imath.git
compile_deps openxr release-1.0.24 https://github.com/KhronosGroup/OpenXR-SDK.git
compile_deps OpenCOLLADA v1.6.68 https://github.com/KhronosGroup/OpenCOLLADA.git
compile_deps openexr v2.5.8 https://github.com/AcademySoftwareFoundation/openexr.git
compile_deps alembic 1.7.16 https://github.com/alembic/alembic.git

ocio_d="-D OCIO_BUILD_APPS=OFF -D OCIO_BUILD_PYTHON=OFF -D OCIO_BUILD_TESTS=OFF -D OCIO_BUILD_GPU_TESTS=OFF"
if [ $(uname -m) == "aarch64" ]; then
    ocio_d="$ocio_d -D OCIO_USE_SSE=OFF"
fi
compile_deps ocio v2.1.2 https://github.com/AcademySoftwareFoundation/OpenColorIO.git "$ocio_d"

oiio_d="-D STOP_ON_WARNING=OFF -D USE_QT=OFF -D USE_PYTHON=OFF -D USE_FFMPEG=OFF -D USE_OPENVDB=OFF -D BUILD_TESTING=OFF -D OIIO_BUILD_TESTS=OFF -D OIIO_BUILD_TOOLS=OFF"
compile_deps oiio v2.3.16.0 https://github.com/OpenImageIO/oiio.git "$oiio_d"



osl_d="-D CMAKE_CXX_STANDARD=14 -D USE_LLVM_BITCODE=OFF -D USE_PARTIO=OFF -D USE_PYTHON=OFF -D USE_QT=OFF -D INSTALL_DOCS=OFF"
if [ $(uname -m) != "aarch64" ]; then
    osl_d="$osl_d -D USE_SIMD=sse2"
fi
compile_deps osl Release-1.11.17.0 https://github.com/AcademySoftwareFoundation/OpenShadingLanguage.git "$osl_d"
compile_deps osd v3_4_4 https://github.com/PixarAnimationStudios/OpenSubdiv.git "-DNO_TBB=ON -DNO_DOC=ON"

compile_deps embree v3.13.3 https://github.com/embree/embree.git "-DEMBREE_RAY_PACKETS=ON"

if [ $(uname -m) == "aarch64" ]; then
    compile_deps openblas v0.3.20 https://github.com/xianyi/OpenBLAS.git
    compile_deps oidn master https://github.com/Robbie-Luo/oidn-aarch64.git "-DDNNL_BLAS_VENDOR=OPENBLAS"
fi

compile_deps blender v3.2.0 https://github.com/blender/blender.git "-DWITH_OPENVDB=OFF -DWITH_USD=OFF"






    
