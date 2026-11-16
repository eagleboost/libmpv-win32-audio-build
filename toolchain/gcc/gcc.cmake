ExternalProject_Add(gcc
    DEPENDS
        mingw-w64-headers
    # 13-20231111 snapshot was pruned from all GCC mirrors (snapshots only
    # keep the latest weeks) and gcc 13 does not build with GCC16 host
    # compilers. gcc 15.2.0 release builds fine (with the libcody patch).
    URL https://ftp.gnu.org/gnu/gcc/gcc-15.2.0/gcc-15.2.0.tar.xz
         https://mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-15.2.0/gcc-15.2.0.tar.xz
         https://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-15.2.0/gcc-15.2.0.tar.xz
    URL_HASH SHA512=89047a2e07bd9da265b507b516ed3635adb17491c7f4f67cf090f0bd5b3fc7f2ee6e4cc4008beef7ca884b6b71dffe2bb652b21f01a702e17b468cca2d10b2de
    # gcc 13's libcody does not compile with GCC16 host compilers
    # (backport of upstream 07a767c7a50d, via openwrt).
    PATCH_COMMAND patch -p1 -l -i ${CMAKE_CURRENT_SOURCE_DIR}/gcc/gcc-13-libcody-cxx26.patch
    DOWNLOAD_DIR ${SOURCE_LOCATION}
    CONFIGURE_COMMAND <SOURCE_DIR>/configure
        --target=${TARGET_ARCH}
        --prefix=${CMAKE_INSTALL_PREFIX}
        --libdir=${CMAKE_INSTALL_PREFIX}/lib
        --with-sysroot=${CMAKE_INSTALL_PREFIX}
        --program-prefix=cross-
        --disable-multilib
        --enable-languages=c,c++
        --disable-nls
        --disable-shared
        --disable-win32-registry
        --with-arch=${GCC_ARCH}
        --with-tune=generic
        --enable-threads=posix
        --without-included-gettext
        --enable-lto
        --enable-checking=release
        --disable-sjlj-exceptions
    BUILD_COMMAND make -j${MAKEJOBS} all-gcc
    INSTALL_COMMAND make install-strip-gcc
    STEP_TARGETS download install
    LOG_DOWNLOAD 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add_Step(gcc final
    DEPENDS
        mingw-w64-crt
        winpthreads
        gendef
        rustup
    COMMAND ${MAKE}
    COMMAND ${MAKE} install-strip
    WORKING_DIRECTORY <BINARY_DIR>
    LOG 1
)

cleanup(gcc final)
