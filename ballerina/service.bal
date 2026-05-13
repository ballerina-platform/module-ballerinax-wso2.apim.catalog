// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/jballerina.java;
import ballerina/oauth2;

configurable string serviceUrl = "https://apis.wso2.com/api/service-catalog/v1";
configurable string username = "";
configurable string password = "";
configurable string? clientId = ();
configurable string? clientSecret = ();
configurable string tokenUrl = "https://localhost:9443/oauth2/token";
configurable int port = 5050;
configurable string? clientSecureSocketpath = ();
configurable string clientSecureSocketpassword = "";
configurable string? serverCert = ();
configurable string[] scopes = ["service_catalog:service_view", "apim:api_view", "service_catalog:service_write"];
# Controls the serviceUrl registered in the APIM Service Catalog.
# Accepts either a single string or a map of strings:
#
# - `string`: one base URL applied to every service
#   (e.g. `registeredServiceHostUrl = "http://my-alb.example.com"`)
#
# - `map<string>`: per-listener base URLs, keyed by `"host:port"`
#   (e.g. `"localhost:9090" = "http://alb-a.example.com"`).
#   All services on that listener are registered under the mapped base URL.
#
# Each value must be an absolute URL with scheme and host (optional port).
# No trailing slash. No path component.
configurable string|map<string>|() registeredServiceHostUrl = ();

listener Listener 'listener = new Listener(port);

Client apimClient = check new (serviceUrl = serviceUrl, config = {
    auth: {
        username,
        tokenUrl,
        password,
        clientId,
        clientSecret,
        scopes,
        clientConfig: getClientConfig(clientSecureSocketpath, clientSecureSocketpassword)
    },
    secureSocket: getServerCert(serverCert)
});

function publishArtifacts(ServiceArtifact[] artifacts) returns error? {
    foreach ServiceArtifact artifact in artifacts {
        _ = check publishOrUpdateService(artifact);
    }
}

isolated function getArtifacts() returns ServiceArtifact[] = @java:Method {
    'class: "io.ballerina.wso2.apim.catalog.ServiceCatalog"
} external;

function getClientConfig(string? clientSecureSocketpath, string clientSecureSocketpassword)
        returns oauth2:ClientConfiguration {
    if clientSecureSocketpath == () {
        return {secureSocket: {disable: true}};
    }
    return {secureSocket: {cert: {path: clientSecureSocketpath, password: clientSecureSocketpassword}}};
}

function getServerCert(string? serverCert) returns http:ClientSecureSocket? {
    if serverCert != null {
        return {cert: serverCert};
    }
    return {enable: false};
}

function getServiceIdByKey(string serviceKey) returns string|error|() {
    ServiceList res = check apimClient->/services.get('key = serviceKey);
    Service[] services = res.list ?: [];
    return services.length() > 0 ? services[0].id : ();
}

function publishOrUpdateService(ServiceArtifact artifact) returns Service|error {
    string|() serviceId = check getServiceIdByKey(artifact.serviceKey);
    string resolvedServiceUrl = artifact.serviceUrl;
    // Derive "host:port" listener key from the auto-derived serviceUrl
    // ("http://host:port/basePath"): strip scheme then take up to the first "/".
    string withoutScheme = artifact.serviceUrl;
    if withoutScheme.startsWith("https://") {
        withoutScheme = withoutScheme.substring(8);
    } else if withoutScheme.startsWith("http://") {
        withoutScheme = withoutScheme.substring(7);
    }
    int? slashPos = withoutScheme.indexOf("/");
    string serviceIdentifier = slashPos is int
        ? withoutScheme.substring(0, slashPos)
        : withoutScheme;
    string? effectiveBase = ();
    string|map<string>|() hostUrlConfig = registeredServiceHostUrl;
    if hostUrlConfig is string {
        effectiveBase = hostUrlConfig;
    } else if hostUrlConfig is map<string> {
        // Ballerina's TOML parser includes surrounding double-quotes as literal
        // characters in map keys for quoted TOML keys. Normalise before comparing.
        foreach [string, string] [k, v] in hostUrlConfig.entries() {
            string normalizedKey = (k.length() > 1 && k.startsWith("\"") && k.endsWith("\""))
                ? k.substring(1, k.length() - 1)
                : k;
            if normalizedKey == serviceIdentifier {
                effectiveBase = v;
                break;
            }
        }
    }
    if effectiveBase is string && effectiveBase.length() > 0 {
        string base = effectiveBase.endsWith("/")
            ? effectiveBase.substring(0, effectiveBase.length() - 1)
            : effectiveBase;
        resolvedServiceUrl = artifact.name.startsWith("/") ? base + artifact.name : base + "/" + artifact.name;
    }
    if serviceId is () {
        return apimClient->/services.post({
            serviceMetadata: {
                name: artifact.name,
                description: artifact.description,
                'version: artifact.version,
                serviceKey: artifact.serviceKey,
                serviceUrl: resolvedServiceUrl,
                definitionType: artifact.definitionType,
                securityType: artifact.securityType,
                mutualSSLEnabled: artifact.mutualSSLEnabled,
                definitionUrl: resolvedServiceUrl
            },
            inlineContent: artifact.definitionFileContent
        });
    }
    return apimClient->/services/[serviceId].put({
        serviceMetadata: {
            name: artifact.name,
            description: artifact.description,
            'version: artifact.version,
            serviceKey: artifact.serviceKey,
            serviceUrl: resolvedServiceUrl,
            definitionType: artifact.definitionType,
            securityType: artifact.securityType,
            mutualSSLEnabled: artifact.mutualSSLEnabled,
            definitionUrl: resolvedServiceUrl
        },
        inlineContent: artifact.definitionFileContent
    });
}
