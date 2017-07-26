#!/bin/bash -e
# build script for libxml2
. /etc/profile.d/modules.sh

module add ci
module add  zlib
module add xz
module add icu/59_1-gcc-${GCC_VERSION}
module add readline
module add python/2.7.13-gcc-${GCC_VERSION}
# Libxml2 has both a sources file and a tests file, which we need to get
SOURCE_FILE=${NAME}-sources-${VERSION}.tar.gz
TESTS_FILE=${NAME}-tests-${VERSION}.tar.gz
mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}

#  Download the source file
for file in ${SOURCE_FILE} ${TESTS_FILE} ; do
if [ ! -e ${SRC_DIR}/${file}.lock ] && [ ! -s ${SRC_DIR}/${file} ] ; then
  touch  ${SRC_DIR}/${file}.lock
  echo "seems like this is the first build - let's geet the source"
  wget ftp://xmlsoft.org/${NAME}/${file} -O ${SRC_DIR}/${file}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${file}.lock
elif [ -e ${SRC_DIR}/${file}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${file}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${file}
fi
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
done
mkdir -p ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}

# Set flags HT needed for later
ICUCPPFLAGS=`icu-config --cppflags`
export CPPFLAGS="$CPPFLAGS $ICUCPPFLAGS"
export LZMA_CFLAGS="-I$XZ_DIR/include"
export LZMA_LIBS="-L${XZ_DIR}/lib -llzma"
../configure --prefix=${SOFT_DIR} \
--with-icu \
--with-python=${PYTHONHOME} \
--with-lzma=${XZ_DIR}
make
