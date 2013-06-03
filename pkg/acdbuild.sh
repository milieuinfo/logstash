#!/bin/bash

VERSION="$(awk -F\" '/LOGSTASH_VERSION/ {print $2}' $(dirname $0)/../lib/logstash/version.rb)"
DEBVERSION="${VERSION}-$(date +%Y%m%d%H%M)"

if [ "$#" -ne 1 ] ; then
  echo "Usage: $0 <release>"
  echo 
  echo "Example: $0 12.10"
  exit 1
fi

os=ubuntu
release=$1

echo "Building package for ubuntu $release"

destdir=build/
prefix=/opt/logstash

if [ "$destdir/$prefix" != "/" -a -d "$destdir/$prefix" ] ; then
  rm -rf "$destdir/$prefix"
fi

mkdir -p $destdir/$prefix


# install logstash.jar
jar="$(dirname $0)/../build/logstash-$VERSION-flatjar.jar" 
if [ ! -f "$jar" ] ; then
  echo "Unable to find $jar"
  exit 1
fi

cp $jar $destdir/$prefix/logstash.jar

mkdir -p $destdir/etc/logrotate.d
mkdir -p $destdir/etc/init
install -m755 -d -o logstash -g logstash $destdir/var/log/logstash
touch $destdir/var/log/logstash/logstash.log
mkdir -p $destdir/etc/sysconfig
touch $destdir/etc/sysconfig/logstash
install -m644 logrotate.conf $destdir/etc/logrotate.d/
install -m755 logstash.upstart.ubuntu $destdir/etc/init/logstash.conf

description="logstash is a system for managing and processing events and logs"
fpm -s dir -t deb -n logstash -v "$DEBVERSION" \
  -a all --iteration 1-$os \
  --before-install acd/before-install.sh \
  --before-remove acd/before-remove.sh \
  --after-install acd/after-install.sh \
  -f -C $destdir .

