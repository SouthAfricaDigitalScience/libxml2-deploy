#!/bin/bash -e
# check-build script for libxml2
. /etc/profile.d/modules.sh
module load ci
module add xz
module add icu/1_59-gcc-${GCC_VERSION}
module add readline
module  add  gcc/${GCC_VERSION}
module add python/${PYTHON_VERSION}-gcc-${GCC_VERSION}

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
#find  . -type l -exec rm -f {} \;

#make check
#make tests

make install

mkdir -p ${SOFT_DIR}
mkdir -p modules
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
module add icu/1_59-gcc-${GCC_VERSION}
module add readline
module  add  gcc/$::env(GCC_VERSION)
module add python/$::env(PYTHON_VERSION)-gcc-$::env(GCC_VERSION)

module-whatis   "$NAME $VERSION."
setenv       XML2_VERSION       $VERSION
setenv       XML2_DIR           $::env(SOFT_DIR)
prepend-path LD_LIBRARY_PATH   $::env(XML2_DIR)/lib
prepend-path PATH              $::env(XML2_DIR)/bin
prepend-path CFLAGS            "-I$::env(XML2_DIR)/include"
prepend-path LDFLAGS           "-L$::env(XML2_DIR)/lib"
MODULE_FILE
) > modules/$VERSION

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/$VERSION ${LIBRARIES_MODULES}/${NAME}

echo "Testing module"
module avail ${NAME}
module add ${NAME}
