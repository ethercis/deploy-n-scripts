REM  description: Controls Ethercis Server
REM  processname: ecis-server
REM
REM  SCRIPT created 14-07-2017, CCH
REM -----------------------------------------------------------------------------------
REM UNAME=`uname`
REM HOSTNAME=`hostname`
set RUNTIME_HOME=C:\Users\christian\Documents\EtherCIS\home
REM set ECIS_DEPLOY_BASE=C:\Users\christian\Documents\EtherCIS\home\lib
set ECIS_DEPLOY_BASE=C:\Development\Dropbox\eCIS_Development\eCIS-LIB
set APPLIB=%ECIS_DEPLOY_BASE%\applib
set LIB=%ECIS_DEPLOY_BASE%\deploy

REM Mailer configuration
REM ECIS_MAILER=echo

REM use the right jvm library depending on the OS
REM NB: EtherCIS requires java 8
set JAVA_HOME=C:\Java\jre1.8.0_65

#force to use IPv4 so Jetty can bind to it instead of IPv6...
set _JAVA_OPTIONS="-Djava.net.preferIPv4Stack=true"

# runtime parameters
set JVM=%JAVA_HOME%\bin\java
set RUNTIME_ETC=%RUNTIME_HOME%\etc
set RUNTIME_LOG=%RUNTIME_HOME%\log
REM #specifies the query dialect used in HTTP requests (REST)
set RUNTIME_DIALECT=EHRSCAPE
REM # the port address to bind to  
set SERVER_PORT=8080 
REM # the network address to bind to
set SERVER_HOST=192.168.2.101

set JOOQ_DIALECT=POSTGRES
set JOOQ_DB_PORT=5432
set JOOQ_DB_HOST=localhost
set JOOQ_DB_SCHEMA=ethercis
set JOOQ_URL=jdbc:postgresql://%JOOQ_DB_HOST%:%JOOQ_DB_PORT%/%JOOQ_DB_SCHEMA%
set JOOQ_DB_LOGIN=postgres
set JOOQ_DB_PASSWORD=postgres

set CLASSPATH=.\;^
%JAVA_HOME%\lib;^
%LIB%\ecis-core-1.1.1-SNAPSHOT.jar;^
%LIB%\ecis-knowledge-cache-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-ehrdao-1.1.0-SNAPSHOT.jar;^
%LIB%\jooq-pg-1.1.0-SNAPSHOT.jar;^
%LIB%\aql-processor-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-validation-1.0-SNAPSHOT.jar;^
%LIB%\ecis-transform-1.0-SNAPSHOT.jar;^
%LIB%\ecis-servicemanager-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-authenticate-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-knowledge-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-logon-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-resource-access-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-composition-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-partyidentified-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-system-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-ehr-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-vehr-service-1.1.0-SNAPSHOT.jar;^
%LIB%\ecis-query-service-1.0.0-SNAPSHOT.jar;^
%LIB%\ecis-graphql-service-0.1-SNAPSHOT.jar;^
%LIB%\ecis-opt-introspect-1.0-SNAPSHOT.jar;^
%APPLIB%\ehrxml.jar;^
%APPLIB%\oet-parser.jar;^
%APPLIB%\ecis-openehr.jar;^
%APPLIB%\types.jar;^
%APPLIB%\adl-parser-1.0.9.jar;^
%APPLIB%\CompositionTemplate.jar;^
%APPLIB%\openEHR.v1.Template.jar;^
%APPLIB%\composition_xml.jar;^
%APPLIB%\openEHR.v1.OperationalTemplate.jar;^
%APPLIB%\thinkehr-framework-jsonlib-2.3.0-JL32.jar

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
-Djava.rmi.server.hostname=%SERVER_HOST%  ^
-Djooq.dialect=%JOOQ_DIALECT%  ^
-Djooq.url=%JOOQ_URL%  ^
-Djooq.login=%JOOQ_DB_LOGIN%  ^
-Djooq.password=%JOOQ_DB_PASSWORD%  ^
-Druntime.etc=%RUNTIME_ETC%  ^
-Druntime.log=%RUNTIME_LOG%  ^
 com.ethercis.vehr.Launcher  ^
-propertyFile %RUNTIME_ETC%/services.properties  ^
-server_host %SERVER_HOST%  ^
-server_port 8080
 
REM end of file
