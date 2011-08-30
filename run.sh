#!/bin/sh
#
# Little helper script that installs all dependencies for RedNotebook and runs
# it without installing. The script shuld work on all Ubuntu and Debian based
# distros, Fedora and OpenSUSE.
#
# Most of the code was taken from the gnome-shell build script.
# Copyright (C) 2008, Red Hat, Inc.
#

set -e

# Install dependencies ---------------------------------------------------------

PKGS_DEB="python-gtk2 python-gtkspell python-yaml python-webkit"
PKGS_FEDORA="pygtk2 gnome-python2-extras PyYAML pywebkitgtk"
PKGS_OPENSUSE="python-gtk python-yaml python-webkit"

release_file=

if which lsb_release > /dev/null 2>&1; then
  system=`lsb_release -is`
  version=`lsb_release -rs`
elif [ -f /etc/fedora-release ] ; then
  system=Fedora
  release_file=/etc/fedora-release
elif [ -f /etc/SuSE-release ] ; then
  system=SUSE
  release_file=/etc/SuSE-release
fi

if [ x$release_file != x ] ; then
    version=`sed 's/[^0-9\.]*\([0-9\.]\+\).*/\1/' < $release_file`
fi

if test "x$system" = xUbuntu -o "x$system" = xDebian -o "x$system" = xLinuxMint ; then
  reqd=$PKGS_DEB

  if [ ! -x /usr/bin/dpkg-checkbuilddeps ]; then
    echo "Please run 'sudo apt-get install dpkg-dev' and try again."
    echo
    exit 1
  fi

  for pkg in $reqd ; do
      if ! dpkg-checkbuilddeps -d $pkg /dev/null 2> /dev/null; then
        missing="$pkg $missing"
      fi
  done
  if test ! "x$missing" = x; then
    echo "You need to enter your password to install the missing packages $missing"
    sudo apt-get install $missing
  fi
fi

if test "x$system" = xFedora ; then
  reqd=$PKGS_FEDORA

  for pkg in $reqd ; do
      if ! rpm -q $pkg > /dev/null 2>&1; then
        missing="$pkg $missing"
      fi
  done
  if test ! "x$missing" = x; then
    gpk-install-package-name $missing
  fi
fi

if test "x$system" = xSUSE -o "x$system" = "xSUSE LINUX" ; then
  reqd=""
  for pkg in $PKGS_OPENSUSE ; do
      if ! rpm -q $pkg > /dev/null 2>&1; then
        reqd="$pkg $reqd"
      fi
  done
  if test ! "x$reqd" = x; then
    echo "Please run 'su --command=\"zypper install $reqd\"' and try again."
    echo
    exit 1
  fi
fi

# Translate RedNotebook --------------------------------------------------------
python setup.py i18n

# Run RedNotebook --------------------------------------------------------------
python rednotebook/journal.py
