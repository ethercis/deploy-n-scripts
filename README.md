Ethercis Platform Installation
==============================

v1.1.2 Apr 11, 2018

C.Chevalley, Ripple Foundation

How to install an EtherCIS platform (eg. ethercis server + postgresql DB).

Warning
-------

In the following, it is assumed this installation is done with root privileges. Depending on your system
configuration, you may have to use ```sudo``` to perform the commands.

Requirements
------------

Although EtherCIS can be installed on various O/S, we do recommend to deploy on CentOS 7 (or RHEL 7).
The following assumes, the target system has already CentOS 7 installed. To check your version, type the
following within a terminal (SSH):

	#> cat /etc/*-release

For example:
	
	CentOS Linux release 7.0.1406 (Core)
	NAME="CentOS Linux"
	VERSION="7 (Core)"
	ID="centos"
	ID_LIKE="rhel fedora"
	VERSION_ID="7"
	PRETTY_NAME="CentOS Linux 7 (Core)"
	ANSI_COLOR="0;31"
	CPE_NAME="cpe:/o:centos:centos:7"
	HOME_URL="https://www.centos.org/"
	BUG_REPORT_URL="https://bugs.centos.org/"
	
	CentOS Linux release 7.0.1406 (Core)
	CentOS Linux release 7.0.1406 (Core)

The installation process consists in 3 install scripts. If the full installation is performed, this will install:

-  Postgresql 10
-  openJDK 8
-  ethercis scripts (specific to a user; here ~ethercis)

NB1. CentOS is a relatively strengthened Linux distribution, in particular, by default, the local firewall will
 block ethercis ports (REST API, JMX and JVM Debug if applicable), the install scripts will allow pass through
 on this ports if authorized during the installation

NB2. A note for Windows Installation is at the end of this README. 

WARNING: this installation procedure is based on lousy security enforcement. It should not be used as is for
production particularly whenever private personal health data are used.


Installation Process
--------------------

1. Open a new terminal shell on the target system (login as root)
2. Go to a directory where you want to perform the installation from (f.e. /usr/local/src)

	```#> cd /usr/local/src```

3. clone/get the installation repository for v1.1.2 from GitHub (copy the link from GitHub)

see https://www.digitalocean.com/community/tutorials/how-to-install-git-on-centos-7 to install git on your host
if not yet installed:

```sudo make install```
```git --version```
```sudo git clone https://github.com/ethercis/deploy-n-scripts.git```

at this stage, you should have a directory containing the deploy-n-scripts distribution

4. go in the v1.1.2 directory for the following

```cd deploy-n-scripts/ethercis-install/v1.2.0```

change the scripts to be executable

```chmod +x *.sh```

5. Install Postgresql 10 (this can take several minutes...)

    ```#>  ./install-db.sh```

The script will prompt you to perform an update of the OS. We recommend to accept this option (lengthy) since it will 
install/updates all required development tools, utilities required to compile and run EtherCIS.

This install script then will proceed with the installation ofy postgresql-10 on the system, compile and install extensions required by ethercis
(jsquery, temporal_tables), configure the DB under schema ethercis and preload the reference tables.

The script prompt for enabling postgresql start at boot time (recommended)

At the end of the install the following is displayed:

Postgresql version 10 successfully deployed, EtherCIS DB configured

At this stage, it is possible to check the installation with psql:

    #> su - postgres

    psql (10.1)
    Type "help" for help.

    postgres=# \l
                                      List of databases
       Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
    -----------+----------+----------+-------------+-------------+-----------------------
     ethercis  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres         +
               |          |          |             |             | postgres=CTc/postgres+
               |          |          |             |             | ethercis=CTc/postgres
     postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
     template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
     template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
               |          |          |             |             | postgres=CTc/postgres
    (4 rows)
    ethercis=# \q
    -bash-4.2$ exit
    logout
    [root@localhost src]#

Enable trusted connection to postgresql on localhost
----

By default, /var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf sets local authentication to IDENT, this script will
set it to 'trust'

     ./configure-postgresql.sh

    this script will setup a 'trust' setting on any connection on localhost (127.0.0.1)
    the resulting configuration modifies pg_hba.conf to default values
    WARNING: please do not use this configuration for a production system
    whenever going to production, access to postgresql should be controlled and audited
    Do you want to configure pg_hba.conf with default enabling ethercis to connect to the DB [N]? y
    found postgresql service:
      postgresql-10.service
      loaded active running
      PostgreSQL 10 database server
    Enter Postgresql version used on your platform: 10  <---- enter 10 for a standard installation
    configuration complete

Install ethercis server
---

    #> ./ethercis-install.sh

We recommend to use the default settings
Make sure hostname is bound to the IP address (answer 'y' to "Do you want to update system with hostname and
 IP address you have specified")

Running ethercis
----

NB. EtherCIS script is installed in ethercis home directory!

    #> cd ~ethercis
    #> ./ecis-server start

Check if the process is running

    #> jps -l
    19218 com.ethercis.vehr.Launcher


POST INSTALLATION
=================

#### Modifying ethercis launch script environment
ecis-server script uses a property file env.rc (located by default in ethercis home directory).
By default it contains the following:

	export ECIS_HOME=/opt/ecis
	export ECIS_PG_HOST=localhost
	export ECIS_PG_PORT=5432
	export ECIS_PG_SCHEMA=ethercis
	export ECIS_PG_ID=postgres
	export ECIS_PG_PWD=postgres
	export ECIS_REST_HOSTNAME=192.168.2.119
	export ECIS_REST_PORT=8080
	export ECIS_NODE_NAME=ethercis.ripple.org
	export JAVA_HOME=/usr/lib/jvm/java-openjdk

If needed these parameters can be modified with the following restriction:

changing node name involves changing /etc/hosts.

#### Wrong date/time on the system.

By default, CentOS uses chrony, please follow the instructions related to this service to synchronize the local time

#### Checking java version

EtherCIS uses java jre pointed to by $JAVA_HOME (>= 1.8). For example:

	#> $JAVA_HOME/bin/java -version

	openjdk version "1.8.0_151"
	OpenJDK Runtime Environment (build 1.8.0_151-b12)
	OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)

Please modify the environment variable if you use another version of java (f.e. Oracle official distribution).

#### openEHR operational templates

By default, ethercis ships with a collection of precompiled operational templates to help getting started. These
templates are located by default in /etc/opt/ecis/knowledge/operational_templates.

Checking the DB installation
================

This can be quite helpful in case of doubt ;)

1. get a shell for user 'postgres'

```
[root@localhost v1.1.2]# su - postgres
-bash-4.2$
```

2. run psql

```
-bash-4.2$ psql
psql (10.3)
Type "help" for help.
```

3. connect to DB ethercis

```
postgres=# \c ethercis
You are now connected to database "ethercis" as user "postgres".
```

4. Get the list of schema for DB ethercis

```
ethercis=# \dn
  List of schemas
  Name  |  Owner
--------+----------
 ehr    | postgres
 ext    | ethercis
 public | postgres
(3 rows)
```

5. Check if the functions are properly configured

Functions used to encode a composition as canonical json

```
\df ehr.*
                                     List of functions
 Schema |        Name         | Result data type  |      Argument data types       |  Type
--------+---------------------+-------------------+--------------------------------+--------
 ehr    | iso_timestamp       | character varying | timestamp with time zone       | normal
 ehr    | js_archetyped       | json              | text, text                     | normal
 ehr    | js_code_phrase      | json              | text, text                     | normal
 ehr    | js_composition      | json              | uuid                           | normal
 ehr    | js_context          | json              | uuid                           | normal
 ehr    | js_context_setting  | json              | uuid                           | normal
 ehr    | js_dv_coded_text    | json              | text, json                     | normal
 ehr    | js_dv_date_time     | json              | timestamp with time zone, text | normal
 ehr    | js_dv_text          | json              | text                           | normal
 ehr    | js_party            | json              | uuid                           | normal
 ehr    | js_party_identified | json              | text, json                     | normal
 ehr    | js_party_ref        | json              | text, text, text, text         | normal
 ehr    | object_version_id   | json              | uuid, text, integer            | normal
(13 rows)
```

List jsquery extension

```
	\df jsq*     
 								List of functions
         Schema |       Name        | Result data type | Argument data types |  Type
        --------+-------------------+------------------+---------------------+--------
         ext    | jsquery_cmp       | integer          | jsquery, jsquery    | normal
         ext    | jsquery_eq        | boolean          | jsquery, jsquery    | normal
         ext    | jsquery_ge        | boolean          | jsquery, jsquery    | normal
         ext    | jsquery_gt        | boolean          | jsquery, jsquery    | normal
         ext    | jsquery_hash      | integer          | jsquery             | normal
         ext    | jsquery_in        | jsquery          | cstring             | normal
         ext    | jsquery_join_and  | jsquery          | jsquery, jsquery    | normal
         ext    | jsquery_join_or   | jsquery          | jsquery, jsquery    | normal
         ext    | jsquery_json_exec | boolean          | jsquery, jsonb      | normal
         ext    | jsquery_le        | boolean          | jsquery, jsquery    | normal
         ext    | jsquery_lt        | boolean          | jsquery, jsquery    | normal
         ext    | jsquery_ne        | boolean          | jsquery, jsquery    | normal
         ext    | jsquery_not       | jsquery          | jsquery             | normal
         ext    | jsquery_out       | cstring          | jsquery             | normal
        (14 rows)

```

List temporal_table extension

```
	\df ve*
                             List of functions
   Schema   |    Name    | Result data type | Argument data types |  Type
------------+------------+------------------+---------------------+---------
 ext        | versioning | trigger          |                     | trigger
 pg_catalog | version    | text             |                     | normal
(2 rows)
```

6. Have a look on tables

```
ethercis=# \dt ehr.*
                 List of relations
 Schema |         Name          | Type  |  Owner
--------+-----------------------+-------+----------
 ehr    | access                | table | postgres
 ehr    | attestation           | table | postgres
 ehr    | attested_view         | table | postgres
 ehr    | compo_xref            | table | postgres
 ehr    | composition           | table | postgres
 ehr    | composition_history   | table | postgres
 ehr    | concept               | table | postgres
 ehr    | containment           | table | postgres
 ehr    | contribution          | table | postgres
 ehr    | contribution_history  | table | postgres
 ehr    | ehr                   | table | postgres
 ehr    | entry                 | table | postgres
 ehr    | entry_history         | table | postgres
 ehr    | event_context         | table | postgres
 ehr    | event_context_history | table | postgres
 ehr    | heading               | table | postgres
 ehr    | identifier            | table | postgres
 ehr    | language              | table | postgres
 ehr    | participation         | table | postgres
 ehr    | participation_history | table | postgres
 ehr    | party_identified      | table | postgres
 ehr    | schema_version        | table | postgres
 ehr    | session_log           | table | postgres
 ehr    | status                | table | postgres
 ehr    | status_history        | table | postgres
 ehr    | system                | table | postgres
 ehr    | template              | table | postgres
 ehr    | template_heading_xref | table | postgres
 ehr    | template_meta         | table | postgres
 ehr    | terminology_provider  | table | postgres
 ehr    | territory             | table | postgres
(31 rows)
```

Check some contents (only concept, language and territory are pre-populated)

```
ethercis=# select * from ehr.language;
 code  |         description
-------+------------------------------
 af    | Afrikaans
 sq    | Albanian
 ar-sa | Arabic (Saudi Arabia)
 ar-iq | Arabic (Iraq)
 ar-eg | Arabic (Egypt)
 ar-ly | Arabic (Libya)
 ar-dz | Arabic (Algeria)
 ar-ma | Arabic (Morocco)
 ar-tn | Arabic (Tunisia)
 ar-om | Arabic (Oman)
 ar-ye | Arabic (Yemen)
 ar-sy | Arabic (Syria)
 ar-jo | Arabic (Jordan)
 ar-lb | Arabic (Lebano
 ....
```

NB. Don't forget to terminate your SQL statement with ';'


TROUBLE SHOOTING
================

#### If ethercis process is running but does not respond to queries, check the firewall setting with:

	# firewall-cmd --list-all
	
	public (default, active)
	  interfaces: enp0s3
	  sources:
	  services: dhcpv6-client ssh
	  ports: 8080/tcp
	  masquerade: no
	  forward-ports:
	  icmp-blocks:
	  rich rules:

Port 8080 should be open at a minimum.

If you need to open the port after the installation.

1. check the active zone:

```# firewall-cmd --get-active-zones```

```
public
     interfaces: enp0s3
```

2. open the port(s) as required

```# firewall-cmd --zone=public --add-port=8000/tcp --permanent```

```# firewall-cmd --zone=public --add-port=8080/tcp --permanent```

3. Reload the firewall

```# firewall-cmd --reload```

4. check the result as indicated above

#### EtherCIS IP address is not bound to the right interface

The binding should be something similar to:

	#> hostname
	ethercis.ripple.org
	#> hostname -i
	192.168.2.119

That is ethercis will listen at ethercis.ripple.org:8080

#### The DB cannot be reached (error when performing queries)

Check postgresql service status:

	#> systemctl status postgresql-10

if the status is unactive (dead) start the server:

	#> systemctl start postgresql-10

And recheck the status (logs can be checked in /var/lib/pgsql/10/data/log

#### The install process is blocking on YUM (CentOS)

If the installation is blocked with a repeating message telling the following:

```Another app is currently holding the yum lock; waiting for it ```

You can stop the yum update process as follows

```ps ax | grep yum```

And kill the process by:

```kill <PID of the yum update process>```

and check if the process is actually killed (repeat the ps command)

#### Failed to do a 'git clone'

Depending on the OS version (or VM image) git clone can fail with the following error:

```Peer reports incompatible or unsupported protocol version```

This requires updating the OS. One way to do this is to execute:

```yum update -y```

This execution is suggested in install-db script.

NB. The full update can take some time (~30+ mn)

#### Gradle flyway fails

It can happen if pg_hba.conf permission is not properly setup, the authentication for user postgres should be set
to 'trust' during the installation process. The script normally insert a directive to trust any during the installation
process, this is removed at the end of the execution.

Windows Installation Notes
======

Installing PostgreSQL 10
----

The install procedure is using the standard install shell found on PostgreSQL [downloads](https://www.postgresql.org/download/windows/). The installation (generally) is quite easy.

The tricky part is to install the required extensions for EtherCIS to run. These are found in 
package/windows/pg_extensions. Other pre-compiled extensions can be found at:

- [temporal_tables](https://github.com/arkhipov/temporal_tables/releases/tag/v1.2.0)
- [jsquery](http://www.postgresonline.com/journal/archives/375-PostgreSQL-JSQuery-extension-Windows-binaries.html)

If you want to compile these extensions for another OS/PG combination, please refer to this [cookbook](https://wiki.postgresql.org/wiki/Building_and_Installing_PostgreSQL_Extension_Modules). 

EtherCIS launch script for Windows
----

An example script is provided in the scripts repository.



