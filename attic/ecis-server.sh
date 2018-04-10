#!/usr/bin/bash
# description: Controls Ethercis Server
# processname: ecis-server
#
# SCRIPT created 15-10-2015, CCH
#-----------------------------------------------------------------------------------
UNAME=`uname`
export ECIS_DEPLOY_BASE=/opt/ecis
export SYSLIB_SYSTEM=${ECIS_DEPLOY_BASE}/lib/system
export SYSLIB_COMMON=${ECIS_DEPLOY_BASE}/lib/common
export APPLIB=${ECIS_DEPLOY_BASE}/lib/application

# Mailer configuration
ECIS_MAILER=echo

# use the right jvm library depending on the OS
# NB: EtherCIS requires java 8
if [ :${UNAME}: = :Linux: ];
then
  JAVA_HOME=/opt/jdk1.8.0_60/jre
fi
if [ :${UNAME}: = :SunOS: ];
then
  JAVA_HOME=/jdk1.8.0_60/jre
fi

# runtime parameters
export JVM=${JAVA_HOME}/bin/java
export RUNTIME_HOME=/opt/ecis
export RUNTIME_ETC=/etc/opt/ecis
export RUNTIME_LOG=/var/opt/ecis
export RUNTIME_DIALECT=EHRSCAPE  #specifies the query dialect used in HTTP requests (REST)
export SERVER_PORT=8080 # the port address to bind to
export SERVER_HOST=ethercis-test-sg # the network address to bind to

export MAILER_CONF=${RUNTIME_ETC}/xcmail.cf

export JOOQ_DIALECT=POSTGRES
JOOQ_DB_PORT=5432
JOOQ_DB_SCHEMA=ethercis
export JOOQ_URL=jdbc:postgresql://${SERVER_HOST}:${JOOQ_DB_PORT}/${JOOQ_DB_SCHEMA}
export JOOQ_DB_LOGIN=postgres
export JOOQ_DB_PASSWORD=postgres

CLASSPATH=./:\
${JAVA_HOME}/lib:\
${APPLIB}/ecis-servicemanager.jar:\
${APPLIB}/ecis-authenticateservice.jar:\
${APPLIB}/ecis-cacheknowledgeservice.jar:\
${APPLIB}/ecis-logonservice.jar:\
${APPLIB}/ecis-resourceaccessservice.jar:\
${APPLIB}/ecis-compositionservice.jar:\
${APPLIB}/ecis-partyidentifiedservice.jar:\
${APPLIB}/ecis-systemservice.jar:\
${APPLIB}/ecis-ehrservice.jar:\
${APPLIB}/ecis-vehrservice.jar:\
${APPLIB}/ehrxml.jar:\
${APPLIB}/oet-parser.jar:\
${APPLIB}/ecis-openehr.jar:\
${APPLIB}/ecis-common.jar:\
${APPLIB}/ecis-knowledge.jar:\
${APPLIB}/types.jar:\
${APPLIB}/adl-parser-1.0.9.jar

# launch server
# ecis server is run as user ethercis
su - ethercis << _ECIS
case "$1" in
  start)
    echo "ethercis startup"
     ( ${ECIS_MAILER} ${MAILER_CONF} "Callcare Startup" "Manual invocation of server startup" > /dev/null )&
    echo ${CLASSPATH}
    (
	${JVM} \
	-Xmx256M \
	-Xms256M \
	-server \
	-XX:-EliminateLocks \
	-XX:-UseVMInterruptibleIO \
	-cp ${CLASSPATH} \
	-Xdebug \
	-Xrunjdwp:transport=dt_socket,address=8000,suspend=n,server=y \
	-Djava.util.logging.config.file=${RUNTIME_ETC}/logging.properties \
	-Dlog4j.configuration=file:${RUNTIME_ETC}/log4j.xml \
	-Djava.awt.headless=true \
	-Djdbc.drivers=org.postgresql.Driver \
	-Dcom.sun.management.jmxremote \
	-Dcom.sun.management.jmxremote.port=8999 \
	-Dcom.sun.management.jmxremote.ssl=false \
	-Dcom.sun.management.jmxremote.authenticate=false \
	-Djooq.dialect=${JOOQ_DIALECT} \
	-Djooq.url=${JOOQ_URL} \
	-Djooq.login=${JOOQ_DB_LOGIN} \
	-Djooq.password=${JOOQ_DB_PASSWORD} \
	-Druntime.etc=${RUNTIME_ETC} \
	 com.ethercis.vehr.Launcher \
	-useKeyboard false	\
	-logConsole true	\
	-session.name ethercis-test \
	-propertyFile ${RUNTIME_ETC}/services.properties \
 2>> ${RUNTIME_LOG}/ethercis_test.log >> ${RUNTIME_LOG}/ethercis_test.log &    )&
    ;;
  stop)
    ( ${ECIS_MAILER} ${MAILER_CONF} "Ethercis Stop" "Manual invocation of server STOP" > /dev/null )&
    echo "ethercis shutdown"
    pkill java
    ;;
  restart)
    ( ${ECIS_MAILER} ${MAILER_CONF} "Ethercis Restart" "Manual invocation of server RESTART" )&
    echo "ethercis restarting"
    $0 stop
    $0 start
    ;;
  clean)
    (${ECIS_MAILER} ${MAILER_CONF} "Ethercis CLEAR" "Manual invocation of server Clear logs" > dev/null )&
    echo "ethercis clear"
    $0 stop
	rm -rf {RUNTIME_LOG}/ethercis_test.log
    ;;
  *)
    echo "Usage: ecis-server {start|stop|restart|clean}"
    exit 1
esac
_ECIS
exit 0
# end of file

