#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf *
./configure --prefix=${SOFT_DIR} \
--with-zlib=${ZLIB_DIR}/lib
make -j 2
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
module add zlib
setenv       XML2_VERSION       $VERSION
setenv       XML2_DIR          $::env(CVMFS_DIR)/apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(XML2_DIR)/lib
prepend-path PATH              $::env(XML2_DIR)/bin
prepend-path CFLAGS            "-I${XML2_DIR}/include"
prepend-path LDFLAGS           "-L${XML2_DIR}/lib"
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}

echo "Testing module"
module avail ${NAME}
module add ${NAME}
