# EtherCIS v1.3.0 Installation

This provides a simple installation strategy for v1.3.0.

Please note that an actual deployment scenario must match your operational requirements, in particular for 
production; topology and security for example are a key factors to figure out what is the most appropriate
configuration. 

In the following, we address a simple installation in a single directory with a running Postgresql server installed
with script in v1.2.0.

The steps are then:

1. If you are doing an upgrade of an existing installation, please make sure your DB is backup before proceeding with
this installation
2. Install PostgreSQL db and perform initial DB setup (skip this step if previously done)
3. Perform a migration of the DB as described below
4. install the distribution, running the install script 

## Prerequisite

This installation is significantly simpler than previous version. It is assumed that EtherCIS executable jar file has
been created as describe in module distribution.

- Supported OS are Linux (preferably CentOS 7) and Windows 7+.
- Created executable jar (ethercis-*version*-runtime.jar)
- Installed GIT and MAVEN (please check your OS for actual installation)

## Installing a new DB

```markdown
./install-db.sh
```

## Performing an existing DB migration

Please note you also need to configure the PostgreSQL server authentication mechanism (see pg_hba.conf configuration)
The following assumes a trust permission is set to connect db on host 127.0.0.1 with user `postgres`

Then the simple approach is to clone `ehrservice` and run mvn as follows:

```markdown
git clone https://github.com/ethercis/ehrservice
cd ehrservice/ecisdb
mvn compile
mvn flyway:migrate
```

## Installing and Running EtherCIS

Copy directories `config` and `lib` into a repository of your choice (f.e. `~ethercis`), cd into it and execute the 
following command:

```markdown
java -jar lib/ethercis-1.3.0-SNAPSHOT-runtime.jar -propertyFile config/services.properties
```