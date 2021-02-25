#!/bin/sh

mkdir build && cd build

for shared_libs in OFF ON
do
  cmake ${CMAKE_ARGS}\
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=${shared_libs} \
    -DLAPACK_LIBRARIES="-llapack" \
    -DBLAS_LIBRARIES="-lblas" \
    -DCMAKE_AR="${AR}" \
    -DCMAKE_RANLIB="${RANLIB}" \
    -DICB=ON \
    ..
  make install -j${CPU_COUNT} VERBOSE=1
done
ctest --output-on-failure -j${CPU_COUNT}
