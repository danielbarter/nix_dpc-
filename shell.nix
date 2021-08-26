with (import <nixpkgs> {});


mkShell rec {
  buildInputs = [ gcc
                  nvtop
                  cmake
                  ninja
                  cudatoolkit
                ];

  # nvtop can't find shared libraries. Should be fixed in nvtop


  GCC_VERSION = "10.3.0";
  DPCPP_HOME="/home/danielbarter/sycl_workspace";
  CUDA_STUBS = "${pkgs.cudatoolkit}/lib/stubs";
  LIBCXX_INCLUDE="${gcc-unwrapped}/include/c++/${GCC_VERSION}";
  LIBCXX_LIBRARY="${gcc-unwrapped}/lib";

  LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib:${DPCPP_HOME}/llvm/build/lib";


  CONFIGURE="python ${DPCPP_HOME}/llvm/buildbot/configure.py --cuda";
  COMPILE="python ${DPCPP_HOME}/llvm/buildbot/compile.py -j 6";


  BUILD = "./llvm/build/install/bin/clang++ -Wl,-dynamic-linker,${DPCPP_HOME}/ld-linux-x86-64.so.2 -std=c++17 ${DPCPP_HOME}/llvm/build/lib/libsycl.so";


  shellHook = ''
    export CMAKE_INCLUDE_PATH=${LIBCXX_INCLUDE}
    export CMAKE_LIBRARY_PATH=${CUDA_STUBS}
    export CPATH=${LIBCXX_INCLUDE}:${LIBCXX_INCLUDE}/x86_64-unknown-linux-gnu:${glibc.dev}/include:${DPCPP_HOME}/llvm/build/include/sycl:${DPCPP_HOME}/llvm/build/include
    export LIBRARY_PATH=${glibc}/lib:${LIBCXX_LIBRARY}:${LIBCXX_LIBRARY}/gcc/x86_64-unknown-linux-gnu/${GCC_VERSION}

    rm -f crt1.o crtbegin.o crtend.o crti.o crtn.o ld-linux-x86-64.so.2
    ln -s ${glibc}/lib/crt1.o ./crt1.o
    ln -s ${glibc}/lib/crti.o ./crti.o
    ln -s ${glibc}/lib/crtn.o ./crtn.o
    ln -s ${LIBCXX_LIBRARY}/gcc/x86_64-unknown-linux-gnu/${GCC_VERSION}/crtbegin.o ./crtbegin.o
    ln -s ${LIBCXX_LIBRARY}/gcc/x86_64-unknown-linux-gnu/${GCC_VERSION}/crtend.o ./crtend.o
    ln -s ${glibc}/lib/ld-linux-x86-64.so.2 ./ld-linux-x86-64.so.2

  '';



}
