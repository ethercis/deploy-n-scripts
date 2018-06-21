#!/usr/bin/env bash

# setup a running ethercis instance
# create ethercis user if it doesn't yet exist
# install the required libraries and create the file structure
# set the environment variables (for some prompt user)
# install openJDK 8 if java is missing or lower version
# install ntp and activate it (time synchronization)
#
# Christian Chevalley/November 2017
# Ripple Foundation

# checking distribution
filecheck() {
  if [ !  -e $1  ]; then
    echo "$1 not found"
    exit 1
  fi;
}

#if ! [[ -v $1 ]]; then
# echo "Usage is ethercis-install <archive_name>"
# exit 1
#fi
#
#ARCHIVE_NAME=$1

PATH=/usr/bin:$PATH
export PATH

ECIS_VERSION=1.2.0

ECIS_BASE=
ECIS_OPT=${ECIS_BASE}/opt/ecis
ECIS_ETC=${ECIS_BASE}/etc/opt/ecis
ECIS_VAR=${ECIS_BASE}/var/opt/ecis

echo "verifying packages"
filecheck "./ecis_etc"
filecheck "./ecis_opt_bin"
filecheck "./ecis_opt_lib"

echo "Current time on this system is: " `date`
while true; do
  read -p "Do you want to adjust this time? " choice
  case "$choice" in
    y|Y )
      read -p "Enter the current time with the following format: MM/DD/YYYY hh:mm:ss" input_date
      date -s ${input_date}
      break
    ;;
    n|N )
        break;;
    * )
    echo "Please input Y or N"
  esac
done


while true; do
  read -p "Installing, do you want to proceed? " choice
  case "$choice" in
    y|Y )
    break
    ;;
    n|N )
    echo "Terminating on user request"
    exit 1;;
    * )
    echo "Please input Y or N"
  esac
done


if [ -e ${ECIS_OPT}/version.properties ]; then
  echo "Ethercis already installed: "
  cat ${ECIS_OPT}/version.properties
  echo
  while true; do
    read -p "Do you want to overwrite the previous installation? " choice
    case "$choice" in
      y|Y )
      rm -f ${ECIS_OPT}/version.properties
      break
      ;;
      n|N )
      echo "Terminating on user request"
      exit 1;;
      * )
      echo "Please input Y or N"
    esac
  done
fi

#create env.rc from user input
#get PG host/port to listen to

echo "Enter the hostname postgresql binds to, followed by [ENTER] (default [localhost], this can be changed later)"
read PG_HOSTNAME
if [ "${PG_HOSTNAME}" == "" ]; then
    PG_HOSTNAME=localhost
fi

while true; do
    echo "Enter the port postgresql listens to, followed by [ENTER] (default [5432], this can be changed later)"
    read PG_PORT
    if [ "${PG_PORT}" == "" ]; then
        PG_PORT=5432
    fi
    #check is valid numeric value
    numeric='^[0-9]+$'
    if [[ "${PG_PORT}" =~ $numeric ]]; then
        break
    else
        echo "port must be numeric"
    fi
done

echo "Enter the DB schema to use, followed by [ENTER] (default [ethercis], this can be changed later)"
read PG_SCHEMA
if [ "${PG_SCHEMA}" == "" ]; then
    PG_SCHEMA="ethercis"
fi


#get PG logon id
while true; do
    echo "Enter postgres user id, followed by [ENTER] (default [postgres], this can be changed later)"
    read PG_LOGON
    if [ "${PG_LOGON}" == "" ]; then
        PG_LOGON="postgres"
    fi
    break
done

#get PG password
while true; do
    echo "Enter postgres user password, followed by [ENTER] (default [postgres], this can be changed later)"
    read PG_PASSWORD
    if [ "${PG_PASSWORD}" == "" ]; then
        PG_PASSWORD="postgres"
    fi
    break
done

HOSTNAME=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

# REST API config
echo "Enter the hostname or IP address ethercis binds to, followed by [ENTER] (default [$HOSTNAME], this can be changed later)"
read REST_HOSTNAME
if [ "${REST_HOSTNAME}" == "" ]; then
    REST_HOSTNAME=$HOSTNAME
fi

while true; do
    echo "Enter the port ethercis listens to, followed by [ENTER] (default [8080], this can be changed later)"
    read REST_PORT
    if [ "${REST_PORT}" == "" ]; then
        REST_PORT=8080
    fi
    #check is valid numeric value
    numeric='^[0-9]+$'
    if [[ "${REST_PORT}" =~ $numeric ]]; then
        break
    else
        echo "Rest port must be numeric"
    fi
done

while true; do
  read -p "Do you want to use java remote debugging [N]? " choice
  case "$choice" in
    y|Y )
      while true; do
          echo "Enter remote debugging port, followed by [ENTER] (default [8000], this can be changed later)"
          read JVM_DEBUG_PORT
          if [ "${JVM_DEBUG_PORT}" == "" ]; then
              JVM_DEBUG_PORT=8000
          fi
          #check is valid numeric value
          numeric='^[0-9]+$'
          if [[ "${JVM_DEBUG_PORT}" =~ $numeric ]]; then
              break
          else
              echo "JVM debug port must be numeric"
          fi
      done
    break
    ;;
    n|N )
    unset JVM_DEBUG_PORT
    break;;
    * )
    break
  esac
done

while true; do
  read -p "Do you want to use JMX [N]? " choice
  case "$choice" in
    y|Y )
      while true; do
          echo "Enter remote JMX port, followed by [ENTER] (default [8999], this can be changed later)"
          read JMX_PORT
          if [ "${JMX_PORT}" == "" ]; then
              JMX_PORT=8999
          fi
          #check is valid numeric value
          numeric='^[0-9]+$'
          if [[ "${JMX_PORT}" =~ $numeric ]]; then
              break
          else
              echo "JMX port must be numeric"
          fi
      done
    break
    ;;
    n|N )
    unset JMX_PORT
    break;;
    * )
    break
  esac
done

while true; do
  read -p "Do you want to generate a test log [N]? " choice
  case "$choice" in
    y|Y )
    USE_TEST_LOG=true
    break
    ;;
    n|N )
    unset USE_TEST_LOG
    break;;
    * )
    break
  esac
done

echo "Enter the node name for this EtherCIS instance. The node name is used to identify versioned objects such as composition. Followed by [ENTER] (default [ethercis.ripple.org], this can be changed later)"
read NODE_NAME
if [ "${NODE_NAME}" == "" ]; then
    NODE_NAME="ethercis.ripple.org"
fi

echo "The following parameters will be used for this ethercis installation:"
echo
echo "Postgresql hostname : ${PG_HOSTNAME}"
echo "Postgresql port     : ${PG_PORT}"
echo "DB schema           : ${PG_SCHEMA}"
echo "Postgresql login    : ${PG_LOGON}"
echo "Postgresql password : ${PG_PASSWORD}"
echo "Ethercis hostname   : ${REST_HOSTNAME}"
echo "Ethercis port       : ${REST_PORT}"
echo "Ethercis node name  : ${NODE_NAME}"

if [[ -v ${JVM_DEBUG_PORT} ]]; then
  echo "JVM debug port     : ${JVM_DEBUG_PORT}"
fi

if [[ -v ${JMX_PORT} ]]; then
  echo "JMX port           : ${JVM_DEBUG_PORT}"
fi

if [[ -v ${USE_TEST_LOG} ]]; then
  echo "Test log will be generated"
fi

while true; do
  read -p "Do you want to continue? " choice
  case "$choice" in
    y|Y )
    echo "Installing Ethercis..."
    break
    ;;
    n|N )
    echo "Terminating on user request"
    exit 1;;
    * )
    echo "Please input Y or N"
  esac
done

echo "Generating env.rc"
echo "export ECIS_HOME=${ECIS_OPT}" >env.rc
echo "export ECIS_PG_HOST=${PG_HOSTNAME}" >>env.rc
echo "export ECIS_PG_PORT=${PG_PORT}" >>env.rc
echo "export ECIS_PG_SCHEMA=${PG_SCHEMA}" >>env.rc
echo "export ECIS_PG_ID=${PG_LOGON}" >>env.rc
echo "export ECIS_PG_PWD=${PG_PASSWORD}" >>env.rc
echo "export ECIS_REST_HOSTNAME=${REST_HOSTNAME}" >>env.rc
echo "export ECIS_REST_PORT=${REST_PORT}" >>env.rc
echo "export ECIS_NODE_NAME=${NODE_NAME}" >>env.rc

if [[ -v ${JVM_DEBUG_PORT} ]]; then
echo "export ECIS_JVM_DEBUG=${JVM_DEBUG_PORT}" >>env.rc
fi

if [[ -v ${JMX_PORT} ]]; then
echo "export ECIS_JVM_JMX=${JMX_PORT}" >>env.rc
fi

while true; do
  read -p "Do you want to update system with hostname and IP address you have specified (/etc/hosts, /etc/hostname) [N}? " choice
  case "$choice" in
    y|Y )
        echo "binding node name ${NODE_NAME} to ip address ${REST_HOSTNAME}"
        hostname ${NODE_NAME}
        echo ${NODE_NAME}>/etc/hostname
        #TODO: check if entry already exists, if not create it
        echo "${REST_HOSTNAME} ${NODE_NAME}" >>/etc/hosts
        break
    ;;
    n|N )
    break;;
    * )
    break
  esac
done

echo "adding ethercis user"
if [ `grep "^ethercis:" /etc/passwd` ]; then
  echo "ethercis user exists: skipping..."
else
  groupadd ethercis
  useradd -m -d /home/ethercis -g ethercis -s /bin/bash ethercis
  passwd -l ethercis
fi

echo "changing user shell to /bin/bash"
if [ `grep "^root:" /etc/passwd | grep bash` ]; then
  echo "root shell already /bin/bash: skipping...";
else
  usermod -s /bin/bash root
fi

#check current version of java
if type -p java; then
    echo found java executable in PATH
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME
    _java="$JAVA_HOME/bin/java"
else
# installing openjdk 1.8
    yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
fi

JAVA_VERSION=`java -version 2>&1 | awk -F '"' '/version/ {print $2}'`

if [[ "$JAVA_VERSION" > "1.8" ]]; then
    echo version is more than 1.8, continuing...

else
    echo Java version is less than 1.8
    echo installing openjdk 1.8
    yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
fi

#create required directories
if ! [[ -e ~ethercis/logs ]]; then
  mkdir -p ~ethercis/logs
else
  echo "~ethercis/logs already exist, skipping"
fi

if ! [[ -e ${ECIS_ETC} ]]; then
  mkdir -p ${ECIS_ETC}/knowledge/archetypes
  mkdir -p ${ECIS_ETC}/knowledge/operational_templates
  mkdir -p ${ECIS_ETC}/knowledge/backup
  mkdir -p ${ECIS_ETC}/knowledge/templates
else
  echo "${ECIS_ETC} already exist, skipping"
fi

if ! [[ -e ${ECIS_OPT} ]]; then
  mkdir -p ${ECIS_OPT}
  mkdir -p ${ECIS_OPT}/bin
  mkdir -p ${ECIS_OPT}/lib
  mkdir -p ${ECIS_OPT}/lib/deploy
  mkdir -p ${ECIS_OPT}/lib/system
else
  echo "${ECIS_OPT} already exist, skipping"
fi

if ! [[ -e ${ECIS_VAR} ]]; then
  mkdir -p ${ECIS_VAR}
else
  echo "${ECIS_VAR} already exist, skipping"
fi

#install the distribution archive
cp -r ./ecis_etc/* ${ECIS_ETC}
cp -r ./ecis_opt_bin/* ${ECIS_OPT}/bin
cp -r ./ecis_opt_lib/* ${ECIS_OPT}/lib

# Give ethercis user permission access various directories
chown -R ethercis:ethercis ~ethercis
chown -R ethercis:ethercis ${ECIS_ETC}
chown -R ethercis:ethercis ${ECIS_VAR}
chown -R ethercis:ethercis ${ECIS_OPT}

chmod -R 755 ${ECIS_ETC}
chmod -R 755 ${ECIS_OPT}

#update JAVA_HOME from the current version and update env.rc
cp env.rc ~ethercis
chown ethercis:ethercis ~ethercis/env.rc
echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> ~ethercis/env.rc

#create ecis server launch script based on set environment
#ethercis launch script is now specific to a user (allows multiple instances, debug etc.)
cd ~ethercis
DATE_NOW=`date`

if [[ -v ${JVM_DEBUG_PORT} ]]; then
ENABLE_DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,address=\${ECIS_JVM_DEBUG},suspend=n,server=y "
fi

if [[ -v ${JMX_PORT} ]]; then
ENABLE_JMX="-Dcom.sun.management.jmxremote \
	-Dcom.sun.management.jmxremote.port=\${ECIS_JVM_JMX} \
    -Dcom.sun.management.jmxremote.local.only=false \
	-Dcom.sun.management.jmxremote.ssl=false \
	-Dcom.sun.management.jmxremote.authenticate=false "
fi

if [[ -v ${USE_TEST_LOG} ]]; then
ENABLE_DEBUG_LOG="2>> \${RUNTIME_LOG}/ethercis_test.log >> \${RUNTIME_LOG}/ethercis_test.log"
else
ENABLE_DEBUG_LOG="2>> /dev/null >> /dev/null"
fi

#ENABLE_MAILER_START="( \${ECIS_MAILER} \${MAILER_CONF} \"EtherCIS Startup\" \"Manual invocation of server startup\" > /dev/null )&"
#ENABLE_MAILER_STOP="( \${ECIS_MAILER} \${MAILER_CONF} \"EtherCIS Shutdown\" \"Manual invocation of server shutdown\" > /dev/null )&"
#ENABLE_MAILER_RESTART="( \${ECIS_MAILER} \${MAILER_CONF} \"EtherCIS Restart\" \"Manual invocation of server restart\" > /dev/null )&"

if [ ! -e ~ethercis/ecis-server ]; then
    echo "creating EtherCIS launch script"
    cat > ~ethercis/ecis-server << STARTUP
#!/usr/bin/env bash
# EtherCIS server script
# script created on $DATE_NOW by user $USER

source ~ethercis/env.rc

export LIB_DEPLOY=${ECIS_OPT}/lib/deploy
export SYSLIB=${ECIS_OPT}/lib/system

export _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"

# runtime parameters
export JVM=\${JAVA_HOME}/bin/java
export RUNTIME_HOME=${ECIS_OPT}
export RUNTIME_ETC=${ECIS_ETC}
export RUNTIME_LOG=${ECIS_VAR}
export RUNTIME_DIALECT=EHRSCAPE  #specifies the query dialect used in HTTP requests (REST)
export SERVER_PORT=\${ECIS_REST_PORT} # the port address to bind to
export SERVER_HOST=\${ECIS_REST_HOST} # the network address to bind to

export JOOQ_DIALECT=POSTGRES
JOOQ_DB_PORT=\${ECIS_PG_PORT}
JOOQ_DB_HOST=\${ECIS_PG_HOST}
JOOQ_DB_SCHEMA=\${ECIS_PG_SCHEMA}
export JOOQ_URL=jdbc:postgresql://\${JOOQ_DB_HOST}:\${JOOQ_DB_PORT}/\${JOOQ_DB_SCHEMA}
export JOOQ_DB_LOGIN=\${ECIS_PG_ID}
export JOOQ_DB_PASSWORD=\${ECIS_PG_PWD}

export CLASSPATH=\$LIB_DEPLOY/${ECIS_VERSION}/*:\$SYSLIB/ecis-dependencies/*:\$SYSLIB/openehr-java-lib/*

# launch server
# ecis server is run as user ethercis
su - ethercis << _ECIS
case "\$1" in
  start)
    echo "ethercis startup"
    echo "Environment"
    echo "==================================="
    echo "CLASSPATH: \${CLASSPATH}"
    echo "RUNTIME ETC: \${RUNTIME_ETC}"
    echo "NODE NAME: \${ECIS_NODE_NAME}"
    echo "SERVER HOST: \${ECIS_REST_HOSTNAME}"
    echo "SERVER PORT: \${ECIS_REST_PORT}"
    echo "DB HOST: \${JOOQ_URL}"
    echo "DEBUG LOG: \${RUNTIME_LOG}"
    echo "==================================="

     ${ENABLE_MAILER_START}
    (
    echo "launching vEhr...."
	\${JVM} \
	-Xmx256M \
	-Xms256M \
	-server \
	-XX:-EliminateLocks \
	-XX:-UseVMInterruptibleIO \
	-cp \${CLASSPATH} \
	-Djava.util.logging.config.file=\${RUNTIME_ETC}/logging.properties \
	-Dlog4j.configurationFile=file:\${RUNTIME_ETC}/log4j.xml \
	-Djava.net.preferIPv4Stack=true \
	-Djava.awt.headless=true \
	-Djdbc.drivers=org.postgresql.Driver \
	${ENABLE_DEBUG} \
    -Dserver.node.name=\${ECIS_NODE_NAME} \
    ${ENABLE_JMX} \
    -Dfile.encoding=UTF-8 \
    -Djava.rmi.server.hostname=\${SERVER_HOST} \
	-Djooq.dialect=\${JOOQ_DIALECT} \
	-Djooq.url=\${JOOQ_URL} \
	-Djooq.login=\${JOOQ_DB_LOGIN} \
	-Djooq.password=\${JOOQ_DB_PASSWORD} \
	-Druntime.etc=\${RUNTIME_ETC} \
	 com.ethercis.vehr.Launcher \
	-propertyFile /etc/opt/ecis/services.properties \
    -server_host \${ECIS_REST_HOSTNAME} \
    -server_port \${ECIS_REST_PORT} \
    ${ENABLE_DEBUG_LOG} &    )&
    ;;
  stop)
    ${ENABLE_MAILER_STOP}
    echo "ethercis shutdown"
    pkill java
    ;;
  restart)
      ${ENABLE_MAILER_RESTART}
    echo "ethercis restarting"
    \$0 stop
    \$0 start
    ;;
  clean)
    (\${ECIS_MAILER} \${MAILER_CONF} "Ethercis CLEAR" "Manual invocation of server Clear logs" > dev/null )&
    echo "ethercis clear"
    \$0 stop
	rm -rf \${RUNTIME_LOG}/ethercis_test.log
    ;;
  *)
    echo "Usage: ecis-server {start|stop|restart|clean}"
    exit 1
esac
_ECIS
exit 0
STARTUP
fi

while true; do
  read -p "Do you want to configure the local firewall [N]? " choice
  case "$choice" in
    y|Y )
        #do some local firewall tweaking to enable the defined ports and interface
        echo "opening firewall to ethercis ports, please wait..."

        firewall-cmd --zone=public --add-port=${REST_PORT}/tcp --permanent

        if [[ -v ${JVM_DEBUG_PORT} ]]; then
        firewall-cmd --zone=public --add-port=${JVM_DEBUG_PORT}/tcp --permanent
        fi

        if [[ -v ${JMX_PORT} ]]; then
        firewall-cmd --zone=public --add-port=${JMX_PORT}/tcp --permanent
        fi

        firewall-cmd --reload      break
        echo "firewall setting done"
    ;;
    n|N )
        break;;
    * )
    break
  esac
done

chmod +x ~ethercis/ecis-server

#create the version install file
echo "EtherCIS installed on ${DATE_NOW} by $USER"> ${ECIS_OPT}/version.properties
echo "Postgresql hostname: ${PG_HOSTNAME}">> ${ECIS_OPT}/version.properties
echo "Postgresql port    : ${PG_PORT}">> ${ECIS_OPT}/version.properties
echo "DB Schema          : ${PG_SCHEMA}" >>${ECIS_OPT}/version.properties
echo "Postgresql login   : ${PG_LOGON}">> ${ECIS_OPT}/version.properties
echo "Postgresql password: ******">> ${ECIS_OPT}/version.properties
echo "Ethercis hostname  : ${REST_HOSTNAME}">> ${ECIS_OPT}/version.properties
echo "Ethercis port      : ${REST_PORT}">> ${ECIS_OPT}/version.properties
echo "Ethercis node name : ${NODE_NAME}">> ${ECIS_OPT}/version.properties

if [[ -v ${JVM_DEBUG_PORT} ]]; then
  echo "JVM debug port     : ${JVM_DEBUG_PORT}">> ${ECIS_OPT}/version.properties
fi

if [[ -v ${JMX_PORT} ]]; then
  echo "JMX port           : ${JVM_DEBUG_PORT}">> ${ECIS_OPT}/version.properties
fi

if [[ -v ${USE_TEST_LOG} ]]; then
  echo "Test log will be generated">> ${ECIS_OPT}/version.properties
fi

echo "Installation complete"
echo "to start ethercis, use command 'ecis-server start'"
echo "to connect to the DB, make sure 'trust' is set for user connecting on 127.0.0.1"
echo "see https://www.postgresql.org/docs/10/static/auth-pg-hba-conf.html for details"

