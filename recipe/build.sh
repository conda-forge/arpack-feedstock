#!/bin/sh

mkdir build && cd build

export FC

if [[ "$target_platform" == "osx-64" ]]; then
  # This is fixed in gfortran 7, but not 4
  TOOLS_DIR=$(dirname $($FC --print-libgcc-file-name))
  if [[ ! -f "$TOOLS_DIR/ld" ]]; then
    ln -sf $LD $TOOLS_DIR/ld
    ln -sf $LD $BUILD_PREFIX/bin/ld
  fi
fi

for shared_libs in OFF ON
do
  cmake \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=${shared_libs} \
    -DLAPACK_LIBRARIES="-llapack" \
    -DBLAS_LIBRARIES="-lblas" \
    -DCMAKE_AR="${AR}" \
    -DCMAKE_RANLIB="${RANLIB}" \
    --debug-try-compile \
    .. || (cat CMakeFiles/FortranCInterface/VerifyC/VerifyFortran.h && \
     nm -g CMakeFiles/FortranCInterface/VerifyC/libVerifyFortran.a && \
     cat CMakeFiles/CMakeOutput.log && cat CMakeFiles/CMakeError.log && \
     cd CMakeFiles/FortranCInterface && make VERBOSE=1 && cd ..\.. && \
     exit 1)

  make install -j${CPU_COUNT}
done
ctest --output-on-failure -j${CPU_COUNT}
