#!/usr/bin/env bash

#declares supported versions and how to access RPMs
#Postgresql 9.6 and 10 are supported (more will be added later)

declare -A pg96rpm

pg96rpm["rhel-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm"
pg96rpm["sl-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-sl96-9.6-3.noarch.rpm"
pg96rpm["centos-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm"
pg96rpm["oraclelinux-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-oraclelinux96-9.6-3.noarch.rpm"
pg96rpm["rhel-7-ppc64le"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-ppc64le/pgdg-redhat96-9.6-3.noarch.rpm"
pg96rpm["centos-7-ppc64le"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-ppc64le/pgdg-centos96-9.6-3.noarch.rpm"
pg96rpm["rhel-6-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-redhat96-9.6-3.noarch.rpm"
pg96rpm["rhel-6-i386"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-i386/pgdg-redhat96-9.6-3.noarch.rpm"
pg96rpm["centos-6-i386"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-centos96-9.6-3.noarch.rpm"
pg96rpm["sl-6-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-sl96-9.6-3.noarch.rpm"
pg96rpm["oraclelinux-6-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-oraclelinux96-9.6-3.noarch.rpmm"
pg96rpm["ami-201503-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-ami201503-96-9.6-2.noarch.rpm"
pg96rpm["fedora-26-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/fedora/fedora-26-x86_64/pgdg-fedora96-9.6-3.noarch.rpm"
pg96rpm["fedora-25-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/fedora/fedora-25-x86_64/pgdg-fedora96-9.6-3.noarch.rpm"
pg96rpm["fedora-24-x86_64"]="https://download.postgresql.org/pub/repos/yum/9.6/fedora/fedora-24-x86_64/pgdg-fedora96-9.6-3.noarch.rpm"

declare -A pg10rpm

pg10rpm["rhel-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-7-x86_64/pgdg-redhat10-10-2.noarch.rpm"
pg10rpm["sl-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-7-x86_64/pgdg-sl10-10-2.noarch.rpm"
pg10rpm["centos-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm"
pg10rpm["oraclelinux-7-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-7-x86_64/pgdg-oraclelinux10-10-2.noarch.rpm"
pg10rpm["rhel-7-ppc64le"]="https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-ppc64le/pgdg-redhat10-10-2.noarch.rpm"
pg10rpm["centos-7-ppc64le"]="https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-ppc64le/pgdg-centos10-10-2.noarch.rpm"
pg10rpm["rhel-6-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-6-x86_64/pgdg-redhat10-10-2.noarch.rpm"
pg10rpm["centos-6-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-6-x86_64/pgdg-centos10-10-2.noarch.rpm"
pg10rpm["sl-6-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-6-x86_64/pgdg-sl10-10-2.noarch.rpm"
pg10rpm["oraclelinux-6-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/redhat/rhel-6-x86_64/pgdg-oraclelinux10-10-2.noarch.rpm"
pg10rpm["fedora-26-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/fedora/fedora-26-x86_64/pgdg-fedora10-10-3.noarch.rpm"
pg10rpm["fedora-25-x86_64"]="https://download.postgresql.org/pub/repos/yum/testing/10/fedora/fedora-25-x86_64/pgdg-fedora10-10-3.noarch.rpm"

PG_VERSION=10

case ${PG_VERSION} in
    10) PG_VERSION_SHORT=10
    ;;
    *) PG_VERSION_SHORT=`echo $PG_VERSION | awk -F '.' '{print $1$2}'`
    ;;
esac

PG_RPM_ARRAY="pg${PG_VERSION_SHORT}rpm"

#figure out OS name and version
#this one is working on CentOS
OS_ID=`cat /etc/*-release | tr "\n" ' '|awk -F"ID=\"" '{sub(/?! .*\"/,"",$2);print $2}'|cut -d '"' -f1`
#this is working on fedora
#OS_ID=`cat /etc/*-release | tr "\n" ' '|awk -F"ID=" '{sub(/?![a-z|A-Z]*/," ",$2);print $2}'|cut -d ' ' -f1`
OS_VERSION=`cat /etc/*-release | tr "\n" ' '|awk -F"release " '{sub(/?! .* \(/,"",$2);print $2}'|cut -d ' ' -f1|awk -F"." '{print $1}'`
ARCHITECTURE=`uname -p`
PG_RPM_ID=${OS_ID}-${OS_VERSION}-${ARCHITECTURE}
PG_RPM=${PG_RPM_ARRAY}[${PG_RPM_ID}]

#perform a global update of the OS (required for CentOS7 as GIT could run with incompatible mode
#initializing DB (RH, CentOS, Fedora23)
if [[ ${OS_ID}-${OS_VERSION} = "rhel-7" ]] || [[ ${OS_ID}-${OS_VERSION} = "centos-7" ]] || ${OS_ID}-${OS_VERSION} = "fedora-23" ]]; then
    while true; do
      read -p "A global update of the OS will be performed, do you wish to do this update [y/n] ? " choice
      case "$choice" in
          y|Y )
            echo "Updating OS (this can take a significant time to complete..."
            yum update -y
            break
            ;;
        n|N )
            break;;
        * )
        echo "Please input Y or N"
      esac
    done
fi

#echo ${PG_RPM}

PG_RPM_ARCHIVE=${!PG_RPM}

#echo ${PG_RPM_ID} ${!PG_RPM}

PG_PACKAGES="postgresql"${PG_VERSION_SHORT}"-server."${ARCHITECTURE}
PG_PACKAGES+=" postgresql"${PG_VERSION_SHORT}"-contrib."${ARCHITECTURE}
PG_PACKAGES+=" postgresql"${PG_VERSION_SHORT}"-devel."${ARCHITECTURE}


echo "Getting RPM " ${PG_RPM_ARCHIVE}

#update the path
export PATH=$PATH:"/usr/pgsql-${PG_VERSION_SHORT}/bin"

mkdir -p install
cd install
wget ${PG_RPM_ARCHIVE}
#get the pgp key
rpm --import http://yum.postgresql.org/RPM-GPG-KEY-PGDG-${PG_VERSION_SHORT}
#install the repos
rpm -ivh *.rpm

#installing required packages
yum -y install ${PG_PACKAGES}

#installing required extension (temporal_tables, jsquery)
yum clean all
yum -y groupinstall "Development tools"
yum -y install git

#now ready to install the extensions
#temporal_tables
echo "Installing temporal_tables extension"
git clone https://github.com/arkhipov/temporal_tables || { echo "Could not clone temporal_tables repository, exiting..." && exit 1; }
cd temporal_tables
make
make install
cd ..
rm -rf temporal_tables
echo "Done"

#jsquery
echo "Installing jsquery extension"
git clone https://github.com/postgrespro/jsquery || { echo "Could not clone jsquery repository, exiting..." && exit 1; }
cd jsquery
make USE_PGXS=1
make install USE_PGXS=1
cd ..
rm -rf jsquery
echo "Done"

#initializing DB (RH, CentOS, Fedora23)
if [[ ${OS_ID}-${OS_VERSION} = "rhel-7" ]] || [[ ${OS_ID}-${OS_VERSION} = "centos-7" ]] || ${OS_ID}-${OS_VERSION} = "fedora-23" ]]; then
    echo "Setup/initialize DB on ${OS_ID}-${OS_VERSION}"
    /usr/pgsql-${PG_VERSION_SHORT}/bin/postgresql-${PG_VERSION_SHORT}-setup initdb
else
    echo "Initialize DB on ${OS_ID}-${OS_VERSION}"
    service postgresql-${PG_VERSION_SHORT} unitdb
fi

PG_CONF_LOCATION=/var/lib/pgsql/${PG_VERSION}/data/postgresql.conf
PG_HBA_LOCATION=/var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf


#update pg_hba.conf to allow trusted login with user ethercis on db ethercis from localhost (required for flyway)
sed -i '1ihost all all 127.0.0.1\/32 trust' ${PG_HBA_LOCATION}

#start service
if [[ ${OS_ID}-${OS_VERSION} = "rhel-7" ]] || [[ ${OS_ID}-${OS_VERSION} = "centos-7" ]] || ${OS_ID}-${OS_VERSION} = "fedora-23" ]]; then
    echo "systemctl enabling/starting DB on ${OS_ID}-${OS_VERSION}"
    systemctl enable postgresql-${PG_VERSION}.service
    systemctl start postgresql-${PG_VERSION}.service
else
    echo "starting DB on ${OS_ID}-${OS_VERSION}"
    service postgresql-${PG_VERSION} start
fi

#clone ethercis ehrservice to create the db
git clone https://github.com/ethercis/ehrservice || { echo "Could not clone ethercis/ehrservice repository, exiting..." && exit 1; }
cd ehrservice/ecisdb
sudo  psql -u postgres -h 127.0.0.1 < createdb.sql

# use maven to perform the migration (make sure maven is installed!)
mvn compile
mvn flyway:migrate

cd ../..

#clean-up the trust directive for user ethercis
sed -i '1d' ${PG_HBA_LOCATION}
#restart postgresql
if [[ ${OS_ID}-${OS_VERSION} = "rhel-7" ]] || [[ ${OS_ID}-${OS_VERSION} = "centos-7" ]] || ${OS_ID}-${OS_VERSION} = "fedora-23" ]]; then
    systemctl restart postgresql-${PG_VERSION}.service
else
    echo "starting DB on ${OS_ID}-${OS_VERSION}"
    service postgresql-${PG_VERSION} restart
fi


#further configuration stuff
echo "Postgresql version ${PG_VERSION} is now installed on host ${HOSTNAME}"
echo "Further configuration in order to get it communicating with peer systems involve:"
echo "- modifying postgresql.conf (${PG_CONF_LOCATION}) and pg_hba.conf ($PG_HBA_LOCATION}) to listen on a network adapter"
echo "- change local firewall setting to enable listening on the defined ip address/port, on CentOS 7, this is as follows:"
echo " [root@localhost ~]# firewall-cmd --permanent --zone=trusted --add-source=<client_ip_address>/<network_mask>"
echo " [root@localhost ~]# firewall-cmd --permanent --zone=trusted --add-port=<postgresql port>/tcp"
echo " [root@localhost ~]# firewall-cmd --reload"
echo
echo "In production, disable postgres password (use psql as user postgres, then command '\password')"
echo "Change user postgres password at Linux level (command: passwd postgres)"
echo

while true; do
    read -p "Do you want Postgresql server to start automatically on boot? [n]" -n 1 -r
    echo
    if [[ $REPLY =~ [Yy]$ ]]; then
        echo "enabling postgresql-${PG_VERSION} server auto boot"
        sudo systemctl enable postgresql-${PG_VERSION}
    fi
    break
done

# House keeping
cd ..
rm -rf install

echo "Postgresql version ${PG_VERSION} successfully deployed, EtherCIS DB configured"


