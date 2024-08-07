# module-ballerinax-wso2.apim.catalog
Integrate Ballerina services with the WSO2 APIM Service catalog feature.
# Ballerina WSO2 APIM Catalog Publisher

[![Build](https://github.com/ballerina-platform/module-ballerinax-wso2.apim.catalog/actions/workflows/build-timestamped-master.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-wso2.apim.catalog/actions/workflows/build-timestamped-master.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-wso2.apim.catalog/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-wso2.apim.catalog)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-wso2.apim.catalog/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-wso2.apim.catalog/actions/workflows/trivy-scan.yml)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-wso2.apim.catalog/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-wso2.apim.catalog/actions/workflows/build-with-bal-test-graalvm.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-wso2.apim.catalog.svg)](https://github.com/ballerina-platform/module-ballerinax-wso2.apim.catalog/commits/master)
[![Github issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-standard-library/module/wso2.apim.catalog.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-standard-library/labels/module%2Fwso2.apim.catalog)

The Ballerina WSO2 APIM catalog publisher module includes ballerina service management tools for publishing service data to WSO2 API manager service catalogs.

## Features

- **Publish Ballerina services to the WSO2 APIM catalog**

## Usage

### Publish Ballerina services to the WSO2 APIM catalog

1. Add `import ballerinax/wso2.apim.catalog as _;` to the default module.
2. Add `remoteManagement=true` to `[build-options]` section of the Ballerina.toml file.
3. Create Config.toml file if it does not exist, and add the following configurations.
    ```toml
    [ballerinax.wso2.apim.catalog]
    serviceUrl="<Url of the service catalog endpoint>"
    tokenUrl="<Url of the token endpoint>"
    username="<username>"
    password="<password>"
    clientId="<clientId>"
    clientSecret="<Client secret>"
    ```
    Modify the configurations to match your WSO2 APIM manager.
4. Run the project with the following command.
    ```shell
    $ bal run
    ```

## Issues and projects

Issues and Projects tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc. please visit Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library).

This repository only contains the source code for the package.

## Building from the source

### Set up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 17 (from one of the following locations).
    * [Oracle](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

2. Export your GitHub personal access token with the read package permissions as follows.

        export packageUser=<Username>
        export packagePAT=<Personal access token>

### Building the source

Execute the commands below to build from source.

1. To build the library:

        ./gradlew clean build

2. Publish ZIP artifact to the local `.m2` repository:

        ./gradlew clean build publishToMavenLocal

3. Publish the generated artifacts to the local Ballerina central repository:

        ./gradlew clean build -PpublishToLocalCentral=true

4. Publish the generated artifacts to the Ballerina central repository:

        ./gradlew clean build -PpublishToCentral=true

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina code of conduct](https://ballerina.io/code-of-conduct).

## Useful links

* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
