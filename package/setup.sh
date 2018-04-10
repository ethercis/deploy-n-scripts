#!/usr/bin/env bash

echo "running $0"

PWD=`pwd`
SETUPDIR=$(cd `dirname $0` && pwd)
INSTALLDIR=`mktemp -d`

if [ -d $INSTALLDIR ]; then
  echo "installing in $INSTALLDIR"
else
  echo "couldnt create temporary directory!"
  echo "press <Enter> to exit"
  read
  exit 1
fi

if [ "x`hostname`" == "xunknown" ]; then
  echo "hostname is unknown!! Please choose a hostname"

  while [ "x`hostname`" == "xunknown" ]; do
    read -e HOSTNAME
    hostname "$HOSTNAME"
    echo "setting hostname to $HOSTNAME"
  done
  echo "$HOSTNAME" > /etc/nodename
fi

echo "extracting installer...(please wait)"
(cd $INSTALLDIR; tar xvpf "$SETUPDIR/install.tar")

echo "installing...(please wait)"
$INSTALLDIR/xcareinst/install.sh

echo "cleaning up..."
cd /
rm -rf $INSTALLDIR

echo "press <Enter> to exit"
read