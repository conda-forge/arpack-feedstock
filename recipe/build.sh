#!/bin/sh

mkdir build && cd build

export FC

if [[ "$target_platform" == osx* ]]; then
  # gfortran is broken on conda. Not sure why
  ln -s $LD $BUILD_PREFIX/bin/ld
  export FFLAGS="$FFLAGS -B$BUILD_PREFIX/bin -v"
  export FCFLAGS="$FCFLAGS -B$BUILD_PREFIX/bin -v"
  #echo "SET_TARGET_PROPERTIES(FortranCInterface PROPERTIES LINKER_LANGUAGE C)" >> $BUILD_PREFIX/share/cmake-*/Modules/FortranCInterface/CMakeLists.txt 
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
