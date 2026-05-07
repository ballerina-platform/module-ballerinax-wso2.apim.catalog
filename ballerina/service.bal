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
# External base URL applied to every service registered in the APIM Service
# Catalog, replacing the auto-derived `http://localhost:<port>`. Use this when
# all services are reachable through the same load balancer or ingress.
# Overridden per-service by `registeredServiceBaseUrls`.
configurable string? registeredServiceBaseUrl = ();
# Per-listener external base URL map, keyed by `"host:port"`
# (e.g. `"localhost:9090"`). All services attached to that listener are
# registered using the mapped base URL. Takes precedence over
# `registeredServiceBaseUrl` for matching listeners. Use this when individual
# listeners are reachable through different load balancers or external hosts.
# Same format rules as `registeredServiceBaseUrl` apply to each value.
configurable map<string> registeredServiceBaseUrls = {};

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
    string withoutScheme = artifact.serviceUrl.startsWith("http://")
        ? artifact.serviceUrl.substring(7)
        : artifact.serviceUrl;
    int? slashPos = withoutScheme.indexOf("/");
    string serviceIdentifier = slashPos is int
        ? withoutScheme.substring(0, slashPos)
        : withoutScheme;
    // Ballerina's TOML parser includes surrounding double-quotes as literal
    // characters in map keys when the Config.toml key was a quoted string.
    // Normalise each key by stripping those quotes before comparing.
    string? perServiceBase = ();
    foreach [string, string] [k, v] in registeredServiceBaseUrls.entries() {
        string normalizedKey = (k.length() > 1 && k.startsWith("\"") && k.endsWith("\""))
            ? k.substring(1, k.length() - 1)
            : k;
        if normalizedKey == serviceIdentifier {
            perServiceBase = v;
            break;
        }
    }
    // Per-service map takes precedence; fall back to the global single value.
    string? effectiveBase = perServiceBase ?: registeredServiceBaseUrl;
    if effectiveBase is string && effectiveBase.length() > 0 {
        string base = effectiveBase.endsWith("/")
            ? effectiveBase.substring(0, effectiveBase.length() - 1)
            : effectiveBase;
        resolvedServiceUrl = base + artifact.name;
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
