#!/bin/bash

VERSION=`awk -F= '/build.number/ {print $2}' /opt/ecis/version.properties`
tar cvpf ethercis-$VERSION.tar \
  /opt/ecis/{application,syslib,version.properties,ethercis_sample} \
  /etc/opt/ecis/{logging_sample.properties,ethercis_sample.xml,ethercis_sample.properties} \
  /var/opt/ecis/log \
  /export/home/ecis/profiles