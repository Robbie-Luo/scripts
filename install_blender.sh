#!/bin/bash
LIB_DIR="/home/lwt595403/lib"
INST_DIR="/opt"
TYPE="release"

if [ $TYPE = "debug" ];then
    BUILD_TYPE="Debug"
else
    BUILD_TYPE="Release"
fi

function add_to_path()
{
    export PATH="$1/bin:$PATH"
    export LD_LIBRARY_PATH="$1/lib:$LD_LIBRARY_PATH"
    export CMAKE_PREFIX_PATH="$1:$CMAKE_PREFIX_PATH"
}

function compile_deps()
{
    SRC=$LIB_DIR/$1
    VERSION=$2
    if [ ! -d $SRC ];then
        git clone --recursive $3 $SRC
    fi
    cd $SRC
    if [ ! -d build ];then
        mkdir build
    fi
    cd build
    cmake_d="-D CMAKE_BUILD_TYPE=Release $4"
    cmake .. -G "Ninja" -DCMAKE_INSTALL_PREFIX=$INST_DIR/deps $cmake_d
    ninja install
}

function compile_TBB()
{
    SRC=$LIB_DIR/oneTBB
    VERSION=$TBB_VERSION
    PREFIX=$INST_DIR/tbb/$VERSION/$TYPE
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/oneapi-src/oneTBB.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build-$TYPE
    fi
    if [ ! -d build-$TYPE ];then
        mkdir build-$TYPE
    fi
    git checkout $VERSION
    cd build-$TYPE
    cmake .. -G "Ninja" -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=$BUILD_TYPE
    ninja install
    
    add_to_path $PREFIX
}

function compile_Python()
{
    SRC=$LIB_DIR/cpython
    VERSION=$PYTHON_VERSION
    PREFIX=$INST_DIR/python/$VERSION
    RUN_PIPE=false
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/python/cpython.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        ../configure --prefix=$PREFIX --with-ensurepip=install --enable-optimizations --enable-ipv6 --enable-loadable-sqlite-extensions --with-dbmliborder=bdb --with-computed-gotos --with-pymalloc --enable-shared
        make install -j
    fi
    add_to_path $PREFIX
    if [ "$RUN_PIPE" = true  ];then
        $PREFIX/bin/python3 -m pip install numpy certifi requests cython zstandard idna
    fi
}

function compile_Boost()
{
    SRC=$LIB_DIR/boost
    VERSION=$BOOST_VERSION
    PREFIX=$INST_DIR/boost/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/boostorg/boost.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        git checkout "boost-$VERSION"
        ./bootstrap.sh --with-python-root=$INST_DIR/python/$PYTHON_VERSION --with-python-version=3.10 
        ./b2 -j96 --prefix=$PREFIX --with-system --with-filesystem --with-thread --with-regex --with-locale --with-date_time --with-wave --with-iostreams --with-python --with-program_options --with-serialization --with-atomic  install 
    fi
    add_to_path $PREFIX
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
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        ../configure --prefix=$PREFIX --arch=arm64 \
        --enable-ffplay --enable-shared --enable-gpl \
        --enable-libx264 --enable-libx265 --enable-libvpx
        make install -j
    fi
    add_to_path $PREFIX

}

function compile_Imath()
{
    SRC=$LIB_DIR/Imath
    VERSION=$IMATH_VERSION
    PREFIX=$INST_DIR/Imath/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/AcademySoftwareFoundation/Imath.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        mkdir build
    fi
    git checkout $VERSION
    cd build
    cmake .. -G "Ninja" -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release
    ninja install
    add_to_path $PREFIX
}

function compile_OpenEXR()
{
    SRC=$LIB_DIR/openexr
    VERSION=$OPENEXR_VERSION
    PREFIX=$INST_DIR/openexr/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/AcademySoftwareFoundation/openexr.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        mkdir build
    fi
    git checkout $VERSION
    cd build
    cmake .. -G "Ninja" -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release
    ninja install
    add_to_path $PREFIX
}

function compile_OpenVDB()
{
    SRC=$LIB_DIR/openvdb
    VERSION=$OPENVDB_VERSION
    PREFIX=$INST_DIR/openvdb/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/AcademySoftwareFoundation/openvdb.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        mkdir build
        git checkout $VERSION
        cd build
        cmake .. -G "Ninja" -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DOPENVDB_BUILD_BINARIES=OFF
        ninja install
    fi
    add_to_path $PREFIX
}

function compile_OCIO()
{
    SRC=$LIB_DIR/ocio
    VERSION=$OCIO_VERSION
    PREFIX=$INST_DIR/ocio/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/AcademySoftwareFoundation/OpenColorIO.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        cmake_d="-D CMAKE_BUILD_TYPE=Release"
        cmake_d="$cmake_d -D CMAKE_INSTALL_PREFIX=$PREFIX"
        cmake_d="$cmake_d -D OCIO_BUILD_APPS=OFF"
        cmake_d="$cmake_d -D OCIO_BUILD_PYTHON=OFF"
        cmake_d="$cmake_d -D OCIO_BUILD_GPU_TESTS=OFF"
        cmake_d="$cmake_d -D CMAKE_CXX_FLAGS='-fPIC -Wno-error=unused-function -Wno-error=deprecated-declaration'"
        if [ $(uname -m) == "aarch64" ]; then
            cmake_d="$cmake_d -D OCIO_USE_SSE=OFF"
        fi
        
        cmake .. -G "Ninja" $cmake_d
        ninja install
    fi
    add_to_path $PREFIX
}

function compile_OIIO()
{
    SRC=$LIB_DIR/oiio
    VERSION=$OIIO_VERSION
    PREFIX=$INST_DIR/oiio/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/OpenImageIO/oiio.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        cmake_d="-D CMAKE_BUILD_TYPE=Release"
        cmake_d="$cmake_d -D CMAKE_INSTALL_PREFIX=$PREFIX"
        cmake_d="$cmake_d -D STOP_ON_WARNING=OFF"
        cmake_d="$cmake_d -D LINKSTATIC=OFF"
        cmake_d="$cmake_d -D USE_QT=OFF"
        cmake_d="$cmake_d -D USE_PYTHON=OFF"
        cmake_d="$cmake_d -D USE_FFMPEG=OFF"
        cmake_d="$cmake_d -D USE_OPENCV=OFF"
        cmake_d="$cmake_d -D USE_OPENVDB=OFF"
        cmake_d="$cmake_d -D BUILD_TESTING=OFF"
        cmake_d="$cmake_d -D OIIO_BUILD_TESTS=OFF"
        cmake_d="$cmake_d -D OIIO_BUILD_TOOLS=OFF"
        cmake_d="$cmake_d -D CMAKE_CXX_FLAGS='-fPIC'"
        cmake .. -G "Ninja"  $cmake_d
        ninja install
    fi
    add_to_path $PREFIX
}

function compile_OSL()
{
    SRC=$LIB_DIR/OpenShadingLanguage
    VERSION=$OSL_VERSION
    PREFIX=$INST_DIR/osl/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/AcademySoftwareFoundation/OpenShadingLanguage.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        cmake_d="-D CMAKE_BUILD_TYPE=Release"
        cmake_d="$cmake_d -D CMAKE_INSTALL_PREFIX=$PREFIX"
        cmake_d="$cmake_d -D CMAKE_CXX_STANDARD=14"
        cmake .. -G "Ninja" $cmake_d
        ninja install
    fi
    add_to_path $PREFIX
}

function compile_OSD()
{
    SRC=$LIB_DIR/OpenSubdiv
    VERSION=$OSD_VERSION
    PREFIX=$INST_DIR/osd/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/PixarAnimationStudios/OpenSubdiv.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        cmake_d="-D CMAKE_BUILD_TYPE=Release"
        cmake_d="$cmake_d -D CMAKE_INSTALL_PREFIX=$PREFIX"
        cmake_d="$cmake_d -D NO_TBB=ON"
        cmake .. -G "Ninja" $cmake_d
        ninja install
    fi
    add_to_path $PREFIX
}

function compile_Embree()
{
    SRC=$LIB_DIR/embree
    VERSION=$EMBREE_VERSION
    PREFIX=$INST_DIR/embree/$VERSION/$TYPE
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/embree/embree.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build-$TYPE
    fi
    if [ ! -d build-$TYPE ];then
        mkdir build-$TYPE
    fi
    git checkout $VERSION
    cd build-$TYPE
    cmake .. -G "Ninja" -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DEMBREE_ISPC_SUPPORT=OFF
    ninja install
    
    add_to_path $PREFIX
}

function compile_Blender()
{
    SRC=$LIB_DIR/blender
    VERSION=$BLENDER_VERSION
    PREFIX=$INST_DIR/blender/$VERSION
    if [ ! -d $SRC ];then
        git clone --recursive https://github.com/blender/blender.git $SRC
    fi
    cd $SRC
    if [ "$1" = true ];then
        rm -rf build
    fi
    if [ ! -d build ];then
        git checkout $VERSION
        mkdir build
        cd build
        cmake_d="-D CMAKE_BUILD_TYPE=Release"
        cmake_d="$cmake_d -D CMAKE_INSTALL_PREFIX=$PREFIX"
        cmake .. -G "Ninja" $cmake_d
        ninja install
    fi
    add_to_path $PREFIX
}


export PATH="/usr/local/bin:/usr/bin:/bin"
export LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib"
export CMAKE_PREFIX_PATH=""

add_to_path $INST_DIR/deps

cmake_d="-D CMAKE_BUILD_TYPE=Release"

compile_deps ptex v2.4.1 https://github.com/wdas/ptex.git
compile_deps libjpeg-turbo 2.1.3 https://github.com/libjpeg-turbo/libjpeg-turbo.git
compile_deps libheif v1.12.0 https://github.com/strukturag/libheif.git
compile_deps Imath v3.1.5 https://github.com/AcademySoftwareFoundation/Imath.git
compile_deps openxr release-1.0.24 https://github.com/KhronosGroup/OpenXR-SDK.git
compile_deps OpenCOLLADA v1.6.68 https://github.com/KhronosGroup/OpenCOLLADA.git
compile_deps alembic 1.7.16 https://github.com/alembic/alembic.git

TBB_VERSION="v2021.5.0"
PYTHON_VERSION="v3.10.5"
BOOST_VERSION="1.78.0"
OPENEXR_VERSION="v2.5.8"
OPENVDB_VERSION="v9.1.0"
OCIO_VERSION="v2.1.2"
OIIO_VERSION="v2.3.16.0"
OSL_VERSION="Release-1.11.17.0"
OSD_VERSION="v3_4_4"
OPENXR_VERSION="1.0.24"
EMBREE_VERSION="v3.13.3"
BLENDER_VERSION="v3.2.0"

compile_TBB
compile_Python
compile_Boost
compile_FFmpeg true
compile_OpenEXR
compile_OpenVDB
compile_OCIO 
compile_OIIO
compile_OSL
compile_Embree
compile_Blender true


