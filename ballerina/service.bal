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
import ballerina/log;

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

listener Listener 'listener = new Listener();

final string[] publishedServiceIds = [];

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
    error? e = ();
    foreach ServiceArtifact artifact in artifacts {
        Service|error res = apimClient->/services.post({
            serviceMetadata: {
                name: artifact.name,
                description: artifact.description,
                'version: artifact.version,
                serviceKey: artifact.serviceKey,
                serviceUrl: artifact.serviceUrl,
                definitionType: artifact.definitionType,
                securityType: artifact.securityType,
                mutualSSLEnabled: artifact.mutualSSLEnabled,
                definitionUrl: artifact.definitionUrl
            },
            inlineContent: artifact.definitionFileContent
        });

        // If there is an error, wait until other artifacts get published
        if res is error {
            e = res;
            continue;
        }

        string? id = res?.id;
        if id == () {
            continue;
        }

        publishedServiceIds.push(id);
    }
    return e;
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

function removeExistingServices(Client apimClient) returns error? {
    foreach string id in publishedServiceIds {
        http:Response|error response = apimClient->/services/[id].delete();
        if response is error {
            log:printError("Error occurred while deleting existing service: ", response);
            return response;
        }
    }
}
