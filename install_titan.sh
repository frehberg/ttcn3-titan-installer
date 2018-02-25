#!/bin/bash 

ECLIPSE_NAME=eclipse
ENABLE_JNI=yes
PRECOMPILED=yes

ECLIPSE_BASE_URL=http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/oxygen/2/eclipse-cpp-oxygen-2-linux-gtk-x86_64.tar.gz
## ECLIPSE_BASE_URL=file:///home/${USER}/pkg/eclipse-cpp-oxygen-2-linux-gtk-x86_64.tar.gz

ECLPSE_TITAN_URL=http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/titan/ttcn3-6.3.pl0-linux64-gcc5.4-ubuntu16.04.tgz
## ECLPSE_TITAN_URL=file:///home/${USER}/pkg/ttcn3-6.3.pl0-linux64-gcc5.4-ubuntu16.04.tgz

ECLIPSE_TITAN_PLUGIN_URL=http://ftp.fau.de/eclipse/titan/TITAN_Designer_and_Executor_plugin-6.3.pl0.zip
## ECLIPSE_TITAN_PLUGIN_URL=file:///home/${USER}/pkg/TITAN_Designer_and_Executor_plugin-6.3.pl0.zip


JDK_HOME=${JDK_HOME:-/usr/lib/jvm/default-java}

##
##
##
abort_if_not_in_path() 
{
   local APTPKG=${2:-${1}}

   echo "Checking for executable '$1'"
   if ! type $1 > /dev/null; then
      echo "Error, environment has no tool: $1"
      echo "      add location  of binary to PATH environment variable in ~/.bashrc "

      exit 1
   fi 
}

##
##
##
abort_if_no_pkg() 
{
   for i in $@; do
      echo "Checking available package '$i'"
      if ! dpkg -l | grep -E "\s.$1" >/dev/null; then
         echo "Error, package not installed on this host: '$i'"
         echo "       install package with the following command"
         echo "       sudo apt-get install -y $@"
         exit 1
      fi
   done 
}


assert_required_packages()
{
   abort_if_no_pkg  curl git 'g++' expect libssl-dev libxml2-dev libncurses5-dev flex bison
  
   # makedepend tools
   abort_if_no_pkg  xutils-dev

   if test "$ENABLE_JNI"; then
      # assert jdk is available
      abort_if_no_pkg default-jdk
   fi
}

## Assert before creating TMP-directories
assert_required_packages

## create a temporary directory for pkg downloads
PKG_DIR=`mktemp -d`



## create the installation directory
WORKSPACE_DIR=${HOME}/ttcn3-tools
BUILD_DIR=${WORKSPACE_DIR}
ECLIPSE_INST_DIR=${WORKSPACE_DIR}/${ECLIPSE_NAME}
TTCN3_INST_DIR=${WORKSPACE_DIR}/titan.core/Install

## check required tooling
abort_if_not_in_path curl
abort_if_not_in_path git

## create the destination directory
rm -rf  ${ECLIPSE_INST_DIR}
mkdir -p ${WORKSPACE_DIR}

##
## build_core
##
setup_ttcn3_compile()
{
   echo "Checking out TTCN3 titan.core from github https://github.com/eclipse/titan.core.git"

   rm -rf "${BUILD_DIR}/titan.core"

   mkdir -p "${BUILD_DIR}"

   pushd "${BUILD_DIR}"

   if ! git clone https://github.com/eclipse/titan.core.git; then
      echo "Failed cloning the titan.core"
      exit 1
   fi

   echo "Building titan.core from github at $PWD/titan.core"

   cd titan.core

   ## setup Makefile.personal
   cat > Makefile.personal <<EOF
TTCN3_DIR := ${TTCN3_INST_DIR}
OPENSSL_DIR := /usr
JDKDIR := ${JDK_HOME}
XMLDIR := /usr
JNI := yes
GEN_PDF := no
EOF

   echo "------------setup------------"
   cat Makefile.personal
   echo "------------/setup------------"

   make

   export TTCN3_DIR=${TTCN3_INST_DIR}
   export PATH=${TTCN3_INST_DIR}/bin/:${PATH}
   export LD_LIBRARY_PATH=${TTCN3_INST_DIR}/lib:${LD_LIBRARY_PATH}
   
   echo "Installing TTCN3 titan.core binaries to ${TTCN3_INST_DIR}"
   make install

   popd
}

setup_env_variables()
{
   ## adding environment variables to ~/.bashrc
   echo "Adding TTC3 tooling environment variable settings to ~/.bashrc"

   echo
   echo "export TTCN3_DIR=${TTCN3_INST_DIR}" 
   echo "export PATH=${TTCN3_INST_DIR}/bin/:\${PATH}"
   echo "export LD_LIBRARY_PATH=${TTCN3_INST_DIR}/lib:\${LD_LIBRARY_PATH}"

   echo "" >> ~/.bashrc
   echo "## ##### Adding TTC3 tooling environment variable settings ####" >> ~/.bashrc
   echo "export TTCN3_DIR=${TTCN3_INST_DIR}" >> ~/.bashrc
   echo "export PATH=${TTCN3_INST_DIR}/bin/:\${PATH}" >> ~/.bashrc
   echo "export LD_LIBRARY_PATH=${TTCN3_INST_DIR}/lib:\${LD_LIBRARY_PATH}" >> ~/.bashrc
}


##
## http_get 
##
http_get() 
{

   URL="$1"
   PREFIX="$2"
   OUTNAME="${3:-}"

   echo "Downloading: ${URL}"

   mkdir -p ${PREFIX}

   # --silent
   if test -z "${OUTNAME}"; then
     ( cd $PREFIX; curl ${URL} -O )
   else
    ( cd $PREFIX; curl ${URL} --output ${OUTNAME} )
   fi
}


setup_eclipse()
{
   http_get "${ECLIPSE_BASE_URL}" "${PKG_DIR}"
   http_get "${ECLIPSE_TITAN_PLUGIN_URL}" "${PKG_DIR}"
   http_get "${ECLPSE_TITAN_URL}" "${PKG_DIR}"

   ## get the filename of the ZIP
   REPO=`for i in  ${PKG_DIR}/TITAN_Designer_and_Executor_plugin*.zip; do echo $i; done`

   pushd ${WORKSPACE_DIR}

   echo "Installing eclipse to ${ECLIPSE_INST_DIR}"
   rm -rf eclipse 

   tar xf ${PKG_DIR}/eclipse-*.tar.gz

   ## Install the TITAN plugins
   echo "Installing eclipse TTCN3-plugins TITAN_Designer/TITAN_Executor to ${ECLIPSE_INST_DIR}"
   ( cd eclipse; ./eclipse -application org.eclipse.equinox.p2.director -noSplash -repository "jar:file://${REPO}!/" -installIU TITAN_Designer.feature.group )

   ( cd eclipse; ./eclipse -application org.eclipse.equinox.p2.director -noSplash -repository "jar:file://${REPO}!/" -installIU TITAN_Executor.feature.group )
   
   popd
   sync
}


setup_ttcn3_precompiled()
{
   ## Install the titan binaries 
   echo "Installing TTCN3 titan.core binaries to ${TTCN3_INST_DIR}"

   rm -rf   ${TTCN3_INST_DIR}
   mkdir -p ${TTCN3_INST_DIR}

   tar -C ${TTCN3_INST_DIR} -xf ${PKG_DIR}/ttcn3-6.3*.tgz
   sync
}

setup_titan_ide_bin()
{
   echo "Installing starter script at  ${HOME}/bin/titan-ide"
   mkdir -p ~/bin

   echo '#!/bin/bash' >  ${HOME}/bin/titan-ide
   echo "echo   \"Starting ${ECLIPSE_INST_DIR}/eclipse\"" >> ${HOME}/bin/titan-ide
   echo "export TTCN3_DIR=${TTCN3_INST_DIR}" >> ${HOME}/bin/titan-ide
   echo "export PATH=${TTCN3_INST_DIR}/bin/:\${PATH}" >>  ${HOME}/bin/titan-ide
   echo "export LD_LIBRARY_PATH=${TTCN3_INST_DIR}/lib:\${LD_LIBRARY_PATH}" >>  ${HOME}/bin/titan-ide
   echo "${ECLIPSE_INST_DIR}/eclipse &"  >>  ${HOME}/bin/titan-ide

   chmod +x  ${HOME}/bin/titan-ide
}

setup_eclipse

if test "${PRECOMPILED}" = "yes"; then
   setup_ttcn3_precompiled
else
   setup_ttcn3_compile
fi

setup_env_variables

setup_titan_ide_bin
  
echo "Finishing installation of"
echo "   eclipse:          ${ECLIPSE_INST_DIR}"
echo "   TTCN3 titan.core: ${TTCN3_INST_DIR}"
echo
echo "Now, execute TITAN IDE with command: ${HOME}/bin/titan-ide"





