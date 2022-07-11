#!/bin/bash
set -e
LIB_DIR="/home/lwt595403/lib"
INST_DIR="/opt"
BUILD_TYPE="Release"
FORCE_REBUILD="false"

echo "$INST_DIR/deps" > $INST_DIR/.profile

source compiler.sh

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

compile cmake v3.23.2 https://github.com/Kitware/CMake.git
compile_release oneTBB v2021.5.0 https://github.com/oneapi-src/oneTBB.git 
compile_py python v3.10.5 https://github.com/python/cpython.git
compile_boost boost 1.78.0 https://github.com/boostorg/boost.git

compile_deps ptex v2.4.1 https://github.com/wdas/ptex.git
compile_deps libjpeg-turbo 2.1.3 https://github.com/libjpeg-turbo/libjpeg-turbo.git
compile_deps libheif v1.12.0 https://github.com/strukturag/libheif.git
compile_deps Imath v3.1.5 https://github.com/AcademySoftwareFoundation/Imath.git
compile_deps openxr release-1.0.24 https://github.com/KhronosGroup/OpenXR-SDK.git
compile_deps OpenCOLLADA v1.6.68 https://github.com/KhronosGroup/OpenCOLLADA.git

compile openexr v2.5.8 https://github.com/AcademySoftwareFoundation/openexr.git
# compile openvdb v9.1.0 https://github.com/AcademySoftwareFoundation/openvdb.git "-DOPENVDB_BUILD_BINARIES=OFF"
compile alembic 1.7.16 https://github.com/alembic/alembic.git

ocio_d="-D OCIO_BUILD_APPS=OFF -D OCIO_BUILD_PYTHON=OFF -D OCIO_BUILD_TESTS=OFF -D OCIO_BUILD_GPU_TESTS=OFF"
if [ $(uname -m) == "aarch64" ]; then
    ocio_d="$ocio_d -D OCIO_USE_SSE=OFF"
fi
compile ocio v2.1.2 https://github.com/AcademySoftwareFoundation/OpenColorIO.git "$ocio_d"

oiio_d="-D STOP_ON_WARNING=OFF -D USE_QT=OFF -D USE_PYTHON=OFF -D USE_FFMPEG=OFF -D USE_OPENVDB=OFF -D BUILD_TESTING=OFF -D OIIO_BUILD_TESTS=OFF -D OIIO_BUILD_TOOLS=OFF"
compile oiio v2.3.16.0 https://github.com/OpenImageIO/oiio.git "$oiio_d"

osl_d="-D CMAKE_CXX_STANDARD=14 -D USE_LLVM_BITCODE=OFF -D USE_PARTIO=OFF -D USE_PYTHON=OFF -D USE_QT=OFF -D INSTALL_DOCS=OFF"
if [ $(uname -m) != "aarch64" ]; then
    osl_d="$osl_d -D USE_SIMD=sse2"
fi
compile osl Release-1.11.17.0 https://github.com/AcademySoftwareFoundation/OpenShadingLanguage.git "$osl_d"
compile osd v3_4_4 https://github.com/PixarAnimationStudios/OpenSubdiv.git "-DNO_TBB=ON -DNO_DOC=ON"


compile_ispc
# compile_llvm llvm-project 12.0.1 https://github.com/llvm/llvm-project.git 
compile_release embree v3.13.3 https://github.com/embree/embree.git "-DEMBREE_RAY_PACKETS=ON"

if [ $(uname -m) == "aarch64" ]; then
    compile openblas v0.3.20 https://github.com/xianyi/OpenBLAS.git
    compile oidn master https://github.com/Robbie-Luo/oidn-aarch64.git "-DDNNL_BLAS_VENDOR=OPENBLAS"
fi

compile_release blender v3.2.0 https://github.com/blender/blender.git "-DWITH_OPENVDB=OFF -DWITH_USD=OFF"






    
