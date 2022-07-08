#!/bin/bash

LIST='
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
'

function add_to_path()
{
    export PATH="$1/bin:$PATH"
    export LD_LIBRARY_PATH="$1/lib:$LD_LIBRARY_PATH"
    export CMAKE_PREFIX_PATH="$1:$CMAKE_PREFIX_PATH"
}

export PATH="/usr/local/bin:/usr/bin:/bin"
export LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib"
export CMAKE_PREFIX_PATH=""

for i in $LIST
do
    add_to_path $i
done


LIST="
/opt/install/python/3.10.5/lib/pkgconfig
"
export PKG_CONFIG_PATH=$(echo $LIST | sed '1d' | sed '$d' | tr '\n' ':')
unset LIST
