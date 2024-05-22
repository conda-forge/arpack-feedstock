#!/bin/sh

set -x

mkdir build && cd build

if [[ "$(echo $fortran_compiler_version | cut -d '.' -f 1)" -gt 9 ]]; then
  export FFLAGS="$FFLAGS -fallow-argument-mismatch"
fi

if [[ $mpi == "openmpi" ]]; then
  export OMPI_ALLOW_RUN_AS_ROOT=1
  export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
  export OMPI_MCA_rmaps_base_oversubscribe=1
  export OMPI_MCA_plm=isolated
  export OMPI_MCA_btl=tcp,self
  export OMPI_MCA_btl_vader_single_copy_mechanism=none

  if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
    export OMPI_CC=$CC
    export OMPI_CXX=$CXX
    export OMPI_FC=$FC

    export CC=mpicc
    export CXX=mpic++
    export F77=mpifort
    export FC=mpifort

    export OPAL_PREFIX=$PREFIX
  fi
fi  

cmake ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS=ON \
  -DLAPACK_LIBRARIES="-llapack" \
  -DBLAS_LIBRARIES="-lblas" \
  -DICB=ON \
  -DMPI=${DMPI} \
  ..

make install -j${CPU_COUNT} VERBOSE=1

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  ctest --output-on-failure -j${CPU_COUNT}
fi
