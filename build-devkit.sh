#!/bin/sh
#---------------------------------------------------------------------------------
# Build scripts for devkitARM/devkitPPC/devkitPSP
#---------------------------------------------------------------------------------

#---------------------------------------------------------------------------------
# specify some urls to download the source packages from
#---------------------------------------------------------------------------------
LIBOGC_VER=20070118
LIBGBA_VER=20060720
LIBNDS_VER=20070327
LIBFAT_VER=20070127
DSWIFI_VER=0.3d
LIBMIRKO_VER=0.9.7
GDB_VER=6.6

LIBOGC="libogc-src-$LIBOGC_VER.tar.bz2"
LIBGBA="libgba-src-$LIBGBA_VER.tar.bz2"
LIBNDS="libnds-src-$LIBNDS_VER.tar.bz2"
LIBFAT="libfat-src-$LIBFAT_VER.tar.bz2"
DSWIFI="dswifi-src-$DSWIFI_VER.tar.bz2"
LIBMIRKO="libmirko-src-$LIBMIRKO_VER.tar.bz2"
GDB="gdb-$GDB_VER.tar.bz2"

LIBOGC_URL="http://downloads.sourceforge.net/devkitpro/$LIBOGC"
LIBGBA_URL="http://downloads.sourceforge.net/devkitpro/$LIBGBA"
LIBNDS_URL="http://downloads.sourceforge.net/devkitpro/$LIBNDS"
DSWIFI_URL="http://downloads.sourceforge.net/devkitpro/$DSWIFI"
LIBFAT_URL="http://downloads.sourceforge.net/devkitpro/$LIBFAT"
LIBMIRKO_URL="http://downloads.sourceforge.net/devkitpro/$LIBMIRKO"
GDB_URL="http://ftp.gnu.org/gnu/gdb/$GDB"

#---------------------------------------------------------------------------------
# Ask whether to download the source packages or not
#---------------------------------------------------------------------------------

VERSION=0

while [ $VERSION -eq 0 ]
do
  echo
  echo "This script will build and install your devkit. Please select the one you require"
  echo
  echo "1: build devkitARM (gba gp32 ds)"
  echo "2: build devkitPPC (gamecube)"
  echo "3: build devkitPSP (PSP)"
  read VERSION

  if [ "$VERSION" -ne 1 -a "$VERSION" -ne 2 -a "$VERSION" -ne 3 ]
  then
      VERSION=0
  fi
done

case "$VERSION" in
  "1" )
    GCC_VER=4.1.2
    BINUTILS_VER=2.17
    NEWLIB_VER=1.15.0
  ;;
  "2" )
    GCC_VER=3.4.6
    BINUTILS_VER=2.16.1
    NEWLIB_VER=1.14.0
  ;;
  "3" )
    GCC_VER=4.1.2
    BINUTILS_VER=2.16.1
    NEWLIB_VER=1.14.0
  ;;
esac

GCC_CORE="gcc-core-$GCC_VER.tar.bz2"
GCC_GPP="gcc-g++-$GCC_VER.tar.bz2"
GCC_CORE_URL="http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/$GCC_CORE"
GCC_GPP_URL="http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/$GCC_GPP"
BINUTILS="binutils-$BINUTILS_VER.tar.bz2"
BINUTILS_URL="http://ftp.gnu.org/gnu/binutils/$BINUTILS"
NEWLIB="newlib-$NEWLIB_VER.tar.gz"
NEWLIB_URL="ftp://sources.redhat.com/pub/newlib/$NEWLIB"



if [ $VERSION -eq 1 ]
then
  basedir='dkarm-eabi'
  package=devkitARM
  builddir=arm-eabi
  target=arm-eabi
  toolchain=DEVKITARM
fi

if [ $VERSION -eq 2 ]
then
  basedir='dkppc'
  package=devkitPPC
  builddir=powerpc-gekko
  target=powerpc-gekko
  toolchain=DEVKITPPC
fi

if [ $VERSION -eq 3 ]
then
  basedir='dkpsp'
  package=devkitPSP
  builddir=psp
  target=psp
  toolchain=DEVKITPSP

  if test "`svn help`"
  then
    SVN="svn"
  else
     echo "ERROR: Please make sure you have 'subversion (svn)' installed."
     exit
  fi
fi

DOWNLOAD=0

while [ $DOWNLOAD -eq 0 ]
do
  echo
  echo "The installation requires binutils-$BINUTILS_VER, gcc$GCC_VER and newlib-$NEWLIB_VER.  Please select an option:"
  echo
  echo "1: I have already downloaded the source packages"
  echo "2: Download the packages for me (requires wget)"
  read DOWNLOAD

  if [ "$DOWNLOAD" -ne 1 -a "$DOWNLOAD" -ne 2 ]
  then
      DOWNLOAD=0
  fi
done

if [ "$DOWNLOAD" -eq 2 ]
then
  if test "`wget -V`"
  then
    WGET=wget
  else
    echo "ERROR: Please make sure you have 'wget' installed."
    exit
  fi
fi


#---------------------------------------------------------------------------------
# Get preferred installation directory and set paths to the sources
#---------------------------------------------------------------------------------
echo
echo "Please enter the directory where you would like '$package' to be installed:"
echo "for mingw/msys you must use <drive>:/<install path> or you will have include path problems"
echo "this is the top level directory for devkitpro, i.e. e:/devkitPro"

read INSTALLDIR
echo

[ ! -z "$INSTALLDIR" ] && mkdir -p $INSTALLDIR && touch $INSTALLDIR/nonexistantfile && rm $INSTALLDIR/nonexistantfile || exit 1;

if [ $DOWNLOAD -eq 1 ]
then
    FOUND=0
    while [ $FOUND -eq 0 ]
    do
      echo
      echo "Please enter the path to the directory that contains the source packages:"
      read SRCDIR

      if [ ! -f $SRCDIR/$BINUTILS ]
      then
	  echo "Error: $BINUTILS not found in $SRCDIR"
	  exit
      else
	  FOUND=1
      fi

      if [ ! -f $SRCDIR/$GCC_GPP ]
      then
    	  echo "Error: $GCC_GPP not found in $SRCDIR"
	      exit
      else
	      FOUND=1
      fi

      if [ ! -f $SRCDIR/$GCC_CORE ]
      then
    	  echo "Error: $GCC_CORE not found in $SRCDIR"
	      exit
      else
	      FOUND=1
      fi

      if [ ! -f $SRCDIR/$NEWLIB ]
      then
	  echo "Error: $NEWLIB not found in $SRCDIR"
	  exit
      else
	  FOUND=1
      fi

      if [ ! -f $SRCDIR/$GDB ]
      then
	  echo "Error: $GDB not found in $SRCDIR"
	  exit
      else
	  FOUND=1
      fi

      if [ $VERSION -eq 1 ]
      then
        if [ ! -f $SRCDIR/$LIBGBA ]
        then
          echo "Error: $LIBGBA not found in $SRCDIR"
          exit
      else
	      FOUND=1
      fi
      if [ ! -f $SRCDIR/$LIBNDS ]
      then
        echo "Error: $LIBNDS not found in $SRCDIR"
	      exit
      else
	      FOUND=1
      fi
      if [ ! -f $SRCDIR/$LIBFAT ]
      then
        echo "Error: $LIBFAT not found in $SRCDIR"
	      exit
      else
	      FOUND=1
      fi
      if [ ! -f $SRCDIR/$DSWIFI ]
      then
        echo "Error: $DSWIFI not found in $SRCDIR"
	      exit
      else
	      FOUND=1
      fi
      if [ ! -f $SRCDIR/$LIBMIRKO ]
      then
        echo "Error: $LIBMIRKO not found in $SRCDIR"
	      exit
      else
	      FOUND=1
      fi
    fi

    if [ $VERSION -eq 2 ]
    then
      if [ ! -f $SRCDIR/$LIBOGC ]
      then
        echo "Error: $LIBOGC not found in $SRCDIR"
	      exit
      else
	      FOUND=1
      fi

    fi

    done

else

    $WGET --passive-ftp -c $BINUTILS_URL || { echo "Error: Failed to download "$BINUTILS; exit; }

    $WGET -c $GCC_CORE_URL || { echo "Error: Failed to download "$GCC_CORE; exit; }

    $WGET -c $GCC_GPP_URL || { echo "Error: Failed to download "$GCC_GPP; exit; }

    $WGET -c $GDB_URL || { echo "Error: Failed to download "$GDB; exit; }

    $WGET --passive-ftp -c $NEWLIB_URL || { echo "Error: Failed to download "$NEWLIB; exit; }

	if [ $VERSION -eq 2 ]
	then
		$WGET -c $LIBOGC_URL || { echo "Error: Failed to download "$LIBOGC; exit; }
	fi


	if [ $VERSION -eq 1 ]
	then
		$WGET -c $LIBNDS_URL || { echo "Error: Failed to download "$LIBNDS; exit; }
		$WGET -c $LIBGBA_URL || { echo "Error: Failed to download "$LIBGBA; exit; }
		$WGET -c $DSWIFI_URL || { echo "Error: Failed to download "$DSWIFI; exit; }
		$WGET -c $LIBFAT_URL || { echo "Error: Failed to download "$LIBFAT; exit; }
		$WGET -c $LIBMIRKO_URL || { echo "Error: Failed to download "$LIBMIRKO; exit; }
	fi
	SRCDIR=`pwd`
fi

BINUTILS_SRCDIR="binutils-$BINUTILS_VER"
GCC_SRCDIR="gcc-$GCC_VER"
GDB_SRCDIR="gdb-$GDB_VER"
NEWLIB_SRCDIR="newlib-$NEWLIB_VER"
LIBOGC_SRCDIR="libogc-$LIBOGC_VER"
LIBGBA_SRCDIR="libgba-$LIBGBA_VER"
LIBFAT_SRCDIR="libfat-$LIBFAT_VER"
DSWIFI_SRCDIR="dswifi-$DSWIFI_VER"
LIBNDS_SRCDIR="libnds-$LIBNDS_VER"
LIBMIRKO_SRCDIR="libmirko-$LIBMIRKO_VER"


#---------------------------------------------------------------------------------
# find proper make
#---------------------------------------------------------------------------------
if [ -z "$MAKE" -a -x "$(which gnumake)" ]; then MAKE=$(which gnumake); fi
if [ -z "$MAKE" -a -x "$(which gmake)" ]; then MAKE=$(which gmake); fi
if [ -z "$MAKE" -a -x "$(which make)" ]; then MAKE=$(which make); fi
if [ -z "$MAKE" ]; then
  echo no make found
  exit 1
fi
echo use $MAKE as make
export MAKE

  
#---------------------------------------------------------------------------------
# find proper gawk
#---------------------------------------------------------------------------------
if [ -z "$GAWK" -a -x "$(which gawk)" ]; then GAWK=$(which gawk); fi
if [ -z "$GAWK" -a -x "$(which awk)" ]; then GAWK=$(which awk); fi
if [ -z "$GAWK" ]; then
  echo no awk found
  exit 1
fi
echo use $GAWK as gawk
export GAWK

#---------------------------------------------------------------------------------
# Add installed devkit to the path, adjusting path on minsys
#---------------------------------------------------------------------------------
TOOLPATH=$(echo $INSTALLDIR | sed -e 's/^\([a-zA-Z]\):/\/\1/')
export PATH=$PATH:$TOOLPATH/$package/bin

echo
echo 'Ready to install '$package' in '$INSTALLDIR
echo
echo 'press return to continue'

read dummy

patchdir=$(pwd)/$basedir/patches
scriptdir=$(pwd)/$basedir/scripts

#---------------------------------------------------------------------------------
# Extract source packages
#---------------------------------------------------------------------------------

BUILDSCRIPTDIR=$(pwd)

echo "Extracting $BINUTILS"
tar -xjvf $SRCDIR/$BINUTILS || { echo "Error extracting "$BINUTILS; exit; }

echo "Extracting $GCC_CORE"
tar -xjvf $SRCDIR/$GCC_CORE || { echo "Error extracting "$GCC_CORE; exit; }

echo "Extracting $GCC_GPP"
tar -xjvf $SRCDIR/$GCC_GPP || { echo "Error extracting "$GCC_GPP; exit; }

echo "Extracting $NEWLIB"
tar -xzvf $SRCDIR/$NEWLIB || { echo "Error extracting "$NEWLIB; exit; }

echo "Extracting $GDB"
tar -xjvf $SRCDIR/$GDB || { echo "Error extracting "$GCC_GPP; exit; }

if [ $VERSION -eq 2 ]
then
  echo "Extracting $LIBOGC"
  mkdir -p $LIBOGC_SRCDIR
  bzip2 -cd $SRCDIR/$LIBOGC | tar -xvf - -C $LIBOGC_SRCDIR  || { echo "Error extracting "$LIBOGC; exit; }
fi

if [ $VERSION -eq 1 ]
then
  echo "Extracting $LIBNDS"
  mkdir -p $LIBNDS_SRCDIR
  bzip2 -cd $SRCDIR/$LIBNDS | tar -xvf - -C $LIBNDS_SRCDIR  || { echo "Error extracting "$LIBNDS; exit; }

  echo "Extracting $LIBGBA"
  mkdir -p $LIBGBA_SRCDIR
  bzip2 -cd $SRCDIR/$LIBGBA | tar -xvf - -C $LIBGBA_SRCDIR || { echo "Error extracting "$LIBGBA; exit; }


  echo "Extracting $LIBFAT"
  mkdir -p $LIBFAT_SRCDIR
  bzip2 -cd $SRCDIR/$LIBFAT | tar -xvf - -C $LIBFAT_SRCDIR || { echo "Error extracting "$LIBFAT; exit; }

  echo "Extracting $DSWIFI"
  mkdir -p $DSWIFI_SRCDIR
  bzip2 -cd $SRCDIR/$DSWIFI | tar -xvf - -C $DSWIFI_SRCDIR || { echo "Error extracting "$DSWIFI; exit; }

  echo "Extracting $LIBMIRKO"
  mkdir -p $LIBMIRKO_SRCDIR
  bzip2 -cd $SRCDIR/$LIBMIRKO | tar -xvf - -C $LIBMIRKO_SRCDIR || { echo "Error extracting "$LIBMIRKO; exit; }
fi


#---------------------------------------------------------------------------------
# apply patches
#---------------------------------------------------------------------------------
patch -p1 -d $BINUTILS_SRCDIR -i $patchdir/binutils-$BINUTILS_VER.patch || { echo "Error patching binutils"; exit; }
patch -p1 -d $GCC_SRCDIR -i $patchdir/gcc-$GCC_VER.patch || { echo "Error patching gcc"; exit; }
patch -p1 -d $NEWLIB_SRCDIR -i $patchdir/newlib-$NEWLIB_VER.patch || { echo "Error patching newlib"; exit; }
if [ -f $patchdir/gdb-$GDB_VER.patch ]
then
  patch -p1 -d $GDB_SRCDIR -i $patchdir/gdb-$GDB_VER.patch || { echo "Error patching gdb"; exit; }
fi

#---------------------------------------------------------------------------------
# Build and install devkit components
#---------------------------------------------------------------------------------
if [ -f $scriptdir/build-gcc.sh ]; then . $scriptdir/build-gcc.sh || { echo "Error building toolchain"; exit; }; cd $BUILDSCRIPTDIR; fi
if [ -f $scriptdir/build-crtls.sh ]; then . $scriptdir/build-crtls.sh || { echo "Error building crtls"; exit; }; cd $BUILDSCRIPTDIR; fi
if [ -f $scriptdir/build-tools.sh ]; then . $scriptdir/build-tools.sh || { echo "Error building tools"; exit; }; cd $BUILDSCRIPTDIR; fi

#---------------------------------------------------------------------------------
# strip binaries
# strip has trouble using wildcards so do it this way instead
#---------------------------------------------------------------------------------
for f in	$INSTALLDIR/$package/bin/* \
		$INSTALLDIR/$package/$target/bin/* \
		$INSTALLDIR/$package/libexec/gcc/$target/$GCC_VER/*
do
	strip $f
done

rm -fr $INSTALLDIR/$package/include/c++/$GCC_VER/$target/bits/stdc++.h.gch

#---------------------------------------------------------------------------------
# strip debug info from libraries
#---------------------------------------------------------------------------------
find $INSTALLDIR/$package/lib/gcc -name *.a -exec $target-strip -d {} \;
find $INSTALLDIR/$package/$target -name *.a -exec $target-strip -d {} \;

#---------------------------------------------------------------------------------
# Clean up temporary files and source directories
#---------------------------------------------------------------------------------

echo "Removing patched sources and build directories"

rm -fr $target
rm -fr $BINUTILS_SRCDIR
rm -fr $NEWLIB_SRCDIR
rm -fr $GCC_SRCDIR

rm -fr $LIBOGC_SRCDIR $LIBGBA_SRCDIR $LIBNDS_SRCDIR $LIBMIRKO_SRCDIR $DSWIFI_SRCDIR $LIBFAT_SRCDIR

echo
echo "Would you like to delete the downloaded source packages? [y/N]"
read answer

if [ "$answer" = "y" -o "$answer" = "Y" ]
then
    echo "removing archives"
    rm -f $SRCDIR/$BINUTILS $SRCDIR/$GCC_CORE $SRCDIR/$GCC_GPP $SRCDIR/$NEWLIB
    if [ $VERSION -eq 1 -o $VERSION -eq 4 ]
    then
      rm -f  $SRCDIR/$LIBGBA $SRCDIR/$LIBNDS $SRCDIR/$LIBMIRKO
    fi
    if [ $VERSION -eq 2 ]
    then
      rm -f  $SRCDIR/$LIBOGC
    fi
fi

echo
echo "note: Add the following to your environment;  DEVKITPRO=$TOOLPATH $toolchain=$TOOLPATH/$package"
echo
