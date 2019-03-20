# Package the distribution in a single JAR

This module is used to package the compilation results from ehrservice and vEhr into a single JAR file.
The exception at this stage is that Marand's FLAT cannot be packaged. 

To produce a single jar, run:

```
mvn clean package
```

The single jar will be created in `user.distribution`. The shaded jars are extracted from `user.deploy`. 

```
        <user.distribution>../../ethercis-distribution</user.distribution>
        <user.deploy>../../ethercis-deploy</user.deploy>
```