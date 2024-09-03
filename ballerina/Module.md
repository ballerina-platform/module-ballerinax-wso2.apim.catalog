# Ballerina WSO2 APIM Catalog Publisher

## Overview

The Ballerina WSO2 APIM catalog publisher module includes ballerina service management tools for publishing service data to WSO2 API manager service catalogs.

## Quickstart

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

## Examples

```ballerina
   import ballerina/http;
   import ballerinax/wso2.apim.catalog as _;
   
   service /sales0 on new http:Listener(9000) {
       // implementation
   }
```

## Useful links

* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
