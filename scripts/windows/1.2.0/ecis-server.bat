REM  description: Controls Ethercis Server
REM  processname: ecis-server
REM
REM  SCRIPT created 14-07-2017, CCH
REM  updated 14.6.18
REM  EtherCIS v1.2.0
REM -----------------------------------------------------------------------------------
@ECHO OFF
REM UNAME=`uname`
REM HOSTNAME=`hostname`
set RUNTIME_HOME=<install home>
REM set ECIS_DEPLOY_BASE=C:\Users\christian\Documents\EtherCIS\home\lib
set ECIS_DEPLOY_BASE=<library path>
set APPLIB=%ECIS_DEPLOY_BASE%\applib
set LIB=%ECIS_DEPLOY_BASE%\deploy

REM Mailer configuration
REM ECIS_MAILER=echo

REM use the right jvm library depending on the OS
REM NB: EtherCIS requires java 8
set JAVA_HOME=C:\Java\jre1.8.0_65

REM #force to use IPv4 so Jetty can bind to it instead of IPv6...
set _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"

REM # runtime parameters
set JVM=%JAVA_HOME%\bin\java
set RUNTIME_ETC=%RUNTIME_HOME%\etc
set RUNTIME_LOG=%RUNTIME_HOME%\log
REM #specifies the query dialect used in HTTP requests (REST)
set RUNTIME_DIALECT=EHRSCAPE
REM # the port address to bind to  
REM set SERVER_PORT=8080 
REM # the network address to bind to
REM # get the host IPV4 address
SERVER_HOST=192.168.2.102

set JOOQ_DIALECT=POSTGRES
set JOOQ_DB_PORT=5432
set JOOQ_DB_HOST=localhost
set JOOQ_DB_SCHEMA=ethercis
set JOOQ_URL=jdbc:postgresql://%JOOQ_DB_HOST%:%JOOQ_DB_PORT%/%JOOQ_DB_SCHEMA%
set JOOQ_DB_LOGIN=postgres
set JOOQ_DB_PASSWORD=postgres

set ETHERCIS_VERSION=1.2.0-SNAPSHOT

echo Launching EtherCIS version %ETHERCIS_VERSION% on host %SERVER_HOST%, port %SERVER_PORT%

set CLASSPATH=.\;^
%JAVA_HOME%\lib;^
%LIB%\ecis-core-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-knowledge-cache-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-ehrdao-%ETHERCIS_VERSION%.jar;^
%LIB%\jooq-pg-%ETHERCIS_VERSION%.jar;^
%LIB%\aql-processor-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-validation-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-transform-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-webtemplate-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-meta-data-cache-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-servicemanager-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-authenticate-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-knowledge-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-logon-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-resource-access-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-composition-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-partyidentified-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-system-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-ehr-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-vehr-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-query-service-%ETHERCIS_VERSION%.jar;^
%LIB%\ecis-graphql-service-0.1-SNAPSHOT.jar;^
%APPLIB%\openehr-java-lib\*;^
%APPLIB%\ecis-dependencies\*

REM launch server
REM ecis server is run as user ethercis
REM echo %CLASSPATH%
%JVM%  ^
-Xmx256M  ^
-Xms256M  ^
-server  ^
-XX:-EliminateLocks  ^
-XX:-UseVMInterruptibleIO  ^
-cp %CLASSPATH%  ^
-Xdebug  ^
-Xrunjdwp:transport=dt_socket,address=8000,suspend=n,server=y  ^
-Djava.util.logging.config.file=%RUNTIME_ETC%/logging.properties  ^
-Dlog4j.configurationFile=%RUNTIME_ETC%/log4j.xml  ^
-Djava.awt.headless=true  ^
-Djdbc.drivers=org.postgresql.Driver  ^
-Dserver.node.name=%HOSTNAME%  ^
-Dfile.encoding=UTF-8  ^
-Djooq.dialect=%JOOQ_DIALECT%  ^
-Djooq.url=%JOOQ_URL%  ^
-Djooq.login=%JOOQ_DB_LOGIN%  ^
-Djooq.password=%JOOQ_DB_PASSWORD%  ^
-Druntime.etc=%RUNTIME_ETC%  ^
-Druntime.log=%RUNTIME_LOG%  ^
-Dserver.hostname=%SERVER_HOST% ^
 com.ethercis.vehr.Launcher  ^
-propertyFile %RUNTIME_ETC%/services.properties

REM -- use services.properties for 
REM -server_host %SERVER_HOST%  ^
REM -server_port 8080
 
REM end of file
