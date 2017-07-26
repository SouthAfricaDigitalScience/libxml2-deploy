#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
module add xz
module add readline
module add gcc-${GCC_VERSION}
module add icu/59_1-gcc-${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
make distclean
ICUCPPFLAGS=`icu-config --cppflags`
export ICULIBS="-L/data/ci-build/generic/centos6/x86_64/icu/59_1-gcc-6.3.0/lib -licui18n -licuuc -licudata"
export CPPFLAGS="$CPPFLAGS $ICUCPPFLAGS"
export LZMA_CFLAGS="-I$XZ_DIR/include"
export LZMA_LIBS="-L${XZ_DIR}/lib -llzma"
export LDFLAGS="$LDFLAGS -L${PYTHON_DIR}/lib"
../configure --prefix=${SOFT_DIR} \
--with-icu \
--with-python=${PYTHONHOME} \
--with-lzma=${XZ_DIR}

make
make install
echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${LIBRARIES_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module add xz
module add icu/59_1-gcc-${GCC_VERSION}
module add readline
module  add  gcc/$::env(GCC_VERSION)
module add python/$::env(PYTHON_VERSION)-gcc-$::env(GCC_VERSION)

setenv       XML2_VERSION       $VERSION
setenv       XML2_DIR          $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(XML2_DIR)/lib
prepend-path PATH              $::env(XML2_DIR)/bin
prepend-path CFLAGS            "-I$::env(XML2_DIR/include"
prepend-path LDFLAGS           "-L$::env(XML2_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}

echo "Testing module"
module avail ${NAME}
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
