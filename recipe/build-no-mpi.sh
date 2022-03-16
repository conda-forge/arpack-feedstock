#!/bin/bash

set -x

rm -rfv build
mkdir build && cd build

if [[ "$(echo $fortran_compiler_version | cut -d '.' -f 1)" -gt 9 ]]; then
  export FFLAGS="$FFLAGS -fallow-argument-mismatch"
fi

for shared_libs in OFF ON
do
  cmake ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=${shared_libs} \
    -DLAPACK_LIBRARIES="-llapack" \
    -DBLAS_LIBRARIES="-lblas" \
    -DICB=ON \
    ..
  make install -j${CPU_COUNT} VERBOSE=1
done

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  ctest --output-on-failure -j${CPU_COUNT}
fi
