#!/usr/bin/env bash
# simple utility to setup basic authentication for postgresql

echo "this script will setup a 'trust' setting on any connection on localhost (127.0.0.1)"
echo "the resulting configuration modifies pg_hba.conf to default values"
echo "WARNING: please do not use this configuration for a production system"
echo "whenever going to production, access to postgresql should be controlled and audited"

while true; do
  read -p "Do you want to configure pg_hba.conf with default enabling ethercis to connect to the DB [N]? " choice
  case "$choice" in
    y|Y )
        echo "found postgresql service:"
        systemctl | grep postgresql
        read -p "Enter Postgresql version used on your platform: " PG_VERSION
        cp ./pg_hba.conf /var/lib/pgsql/${PG_VERSION}/data
        chown postgres:postgres /var/lib/pgsql/${PG_VERSION}/data
        #restart postgresql
        systemctl restart postgresql-${PG_VERSION}
        echo "configuration complete"
        break
    ;;
    n|N )
        break;;
    * )
    break
  esac
done