#!/bin/sh

# set -e

# Determine distribution folder.
OS=`uname`

LOCALINST=.
SHAREINST=

if [ "$OS" = "Linux" ]; then
  BINTYPE=linux
  SCRIPT=`readlink -f $0`
  CPLN="cp -d"
  LOCALINST="$HOME/opt/bakoma"
  LOCALDESK="$HOME/.local/share/applications"
  SHAREINST="/opt/bakoma"
  SHAREDESK="/usr/share/applications"
fi

if [ "$OS" = "Darwin" ]; then
  BINTYPE=MacOS
  SCRIPT=$0
  CPLN=cp
  LOCALINST="$HOME/Applications/BaKoMa TeX/.bakoma"
  LOCALDESK="$HOME/Applications/BaKoMa TeX"
  SHAREINST="/Applications/BaKoMa TeX/.bakoma"
  SHAREDESK="/Applications/BaKoMa TeX"
fi

if [ "$SCRIPT" = "" ]; then
    echo "error: unsupported OS=$OS."
    exit 1
fi

BASEDIR=`dirname $SCRIPT`

# Load configuration
if [ ! -f "$BASEDIR/inst-config" ]; then
    echo "error: could not find configuration $BASEDIR/inst-config"
    exit 1
fi

. "$BASEDIR/inst-config"

SETUPSET="Required"
FULLSET=""
# NOTE: existing of INSTALL.BAT suggests that full disk is there ...
if [ -f "$BASEDIR/install.bat" ]; then
  FULLSET=".bkz+.all.bkz"
fi

BKMUsage()
{
  echo " "
  echo "Installation of $PRODUCTINFO for $OS, Version $VERSION, Revision $REVISION"
  echo " "
  echo "Usage:"
  echo " "
  echo "  $0 --local | --share "
  echo " "
  echo "    --local  - Installs BaKoMa TeX locally"
  echo "               into $LOCALINST"
  echo "    --share  - Installs BaKoMa TeX globally"
  echo "               into $SHAREINST"
if [ \! "$FULLSET" = "" ]; then
  echo "    --full   - Installs all modules available on the CD."
fi
#if [ -f "/usr/bin/pkgbuild" ]; then
#  echo "    --pkg    - Building PKG package."
#fi
  echo " "
  exit 1
}

# Check distribution structure (shell script may be run outside distribution folder)
UPDATEDIR="$BASEDIR/.bakoma/update"
if [ ! -f "$UPDATEDIR/ls-R.net" ]; then
  UPDATEDIR="$BASEDIR/.bakoma/Update"
  if [ ! -f "$UPDATEDIR/ls-R.net" ]; then
    echo "Invalid distribution structure. $UPDATEDIR/ls-R.net is absent." 
    exit 1
  fi
fi

INSTDATA=$BASEDIR/.bakoma/install/bin-$OS.tar.xz

if [ ! -f "$INSTDATA" ]; then
  echo "This distribution do not support installation on $OS."
  echo "There is no installation data $INSTDATA required for $OS." 
  exit 1
fi

if [ ! "$ARCH" = "`uname -m`" ]; then
  echo "Unsupported architecture `uname -m`."
  echo "This distribution supports only '$ARCH' architecture." 
  exit 1
fi

# Check arguments ...
if [ "$1" = "" ]; then
  BKMUsage
  exit 1
fi

# There is folder where BaKoMa TeX will be installed.
INSTDIR=
Mode=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --local | -local )
	INSTDIR=$LOCALINST
	DESKTOP=$LOCALDESK
	Mode="-local"
	echo Install locally into $INSTDIR
	echo Menu files=$DESKTOP
	shift
	;;
    --share | -share )
	INSTDIR=$SHAREINST
	DESKTOP=$SHAREDESK
	Mode="-share"
	echo Install Globally into $INSTDIR
	echo Menu files=$DESKTOP
	shift
	;;
    --pkg | -pkg )
	INSTDIR=./PKGDIR/.bakoma
	DESKTOP=./PKGDIR
	Mode="-local"
	echo Install Locally into $INSTDIR
	echo Menu files=$DESKTOP
	shift
	;;
    --full | -full )
	if [ ! "$FULLSET" = "" ]; then
	  SETUPSET=$FULLSET
	else
	  echo "ERROR: Full install is not relevant from this mini-CD install."
	  BKMUsage
	fi
	shift
	;;
    -*)
	echo ERROR: Unknown option : "$1"
	BKMUsage
	;;
    *)
	BKMUsage
	break
	;;
  esac
done

if [ "$Mode" = "" ]; then 
  echo "ERROR: Undefined installation mode."
  echo "NOTE: One of '--local' or '--share' must be specified."
  exit 1
fi 

if [ -d "$INSTDIR" ]; then
  echo "Target folder $INSTDIR is already exists." 
  echo "Remove it using 'rm -rf $INSTDIR'." 
  exit 1
fi

echo "Creating Target directory $INSTDIR"
mkdir -p "$INSTDIR"
if [ ! -d "$INSTDIR" ]; then
  echo "Can't create target folder $INSTDIR." 
  if [ "$INSTDIR" = "$SHAREINST" ]; then
    echo "Try launch installer with adm privelegies like following:" 
    echo "   sudo $0 --share" 
    echo "Or try install software locally into your home folder like following:"
    echo "   $0 --local" 
  fi
  exit 1
fi
# Boot unpack: bin, etc, SETUP.INI
#/bin/gunzip -d <$BASEDIR/.bakoma/$VERSIONINT/linux.tar.gz | /bin/tar -xvopf - -C "$INSTDIR/"
echo "Unpacking $INSTDATA"
echo "     into $INSTDIR"
tar -xopf "$INSTDATA" -C "$INSTDIR/"
/bin/cp -rf "$UPDATEDIR" "$INSTDIR/Update"
chmod +w "$INSTDIR/Update"

# Unpack configuration files ...
if [ ! -f "$INSTDIR/TEXMF.INI" ]; then
  echo "Unpacking configuration files from $INSTDIR/etc/cfgfiles.tar"
  tar -xopf "$INSTDIR/etc/cfgfiles.tar" -C "$INSTDIR/" 
  TEXMFTemplate=$INSTDIR/etc/TEXMF-Template.INI
  if [ -f "$TEXMFTemplate" ]; then
    echo "Customizing $TEXMFTemplate"
    echo "  using sed with commands " "s/;;$OS;//" " " "s/;;$OS$Mode;//"
    sed -e "s/;;$OS;//" -e "s/;;$OS$Mode;//" "$TEXMFTemplate" >"$INSTDIR/TEXMF.INI"
  fi 	
  if [ ! -f "$INSTDIR/TEXMF.INI" ]; then
    echo "Sorry, $INSTDIR/TEXMF.INI is absent" 
    exit 1
  fi
fi

echo "Running $INSTDIR/bin/$BINTYPE/setupcon" "-s$BASEDIR" -i $SETUPSET
"$INSTDIR/bin/$BINTYPE/setupcon" "-s$BASEDIR" -i $SETUPSET

echo "Setup is finished with exit code *$?*" 
if [ ! -f "$INSTDIR/SETUP.OK" ]; then
  echo "Sorry, $INSTDIR/SETUP.OK is absent" 
  exit 1
fi

# Install .desktop files
#for i in bakoma-texword bakoma-texcode bakoma-dview bakoma-metahelp bakoma-bibedit bakoma-settings
#do
#echo sed "$INSTDIR/etc/$i.desktop" to "$DESKTOP/$i.desktop"
#sed -e "s|/opt/bakoma|$INSTDIR|" \
#	"$INSTDIR/etc/$i.desktop" >"$DESKTOP/$i.desktop"
#done

FINISH="$INSTDIR/etc/$OS-setup.sh"
if [ -f "$FINISH" ]; then
  if [ ! -d "$DESKTOP" ]; then
    echo "Creating missed DESKTOP folder $DESKTOP"
    mkdir -p "$DESKTOP"
  fi
  echo "Executing final adjustments from $FINISH"
  chmod ugo+x "$FINISH"
  "$FINISH" "$INSTDIR" "$DESKTOP" "$VERSION"
fi
  $INSTDIR/bin/$BINTYPE/texcode &
  cat $INSTDIR/bin/$BINTYPE/lic.txt
exit 0

