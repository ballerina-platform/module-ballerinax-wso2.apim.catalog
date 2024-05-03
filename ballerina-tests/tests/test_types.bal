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

import ballerina/constraint;

public type ServiceSchema record {
    Service serviceMetadata;
    record {byte[] fileContent; string fileName;} definitionFile?;
    # Inline content of the document
    string inlineContent?;
};

public type Service record {
    string id?;
    @constraint:String {maxLength: 255, minLength: 1, pattern: re `^[^\*]+$`}
    string name;
    @constraint:String {maxLength: 1024}
    string description?;
    @constraint:String {maxLength: 30, minLength: 1}
    string version;
    @constraint:String {maxLength: 512}
    string serviceKey?;
    string serviceUrl;
    # The type of the provided API definition
    "OAS2"|"OAS3"|"WSDL1"|"WSDL2"|"GRAPHQL_SDL"|"ASYNC_API" definitionType;
    # The security type of the endpoint
    "BASIC"|"DIGEST"|"OAUTH2"|"X509"|"API_KEY"|"NONE" securityType = "NONE";
    # Whether Mutual SSL is enabled for the endpoint
    boolean mutualSSLEnabled = false;
    # Number of usages of the service in APIs
    int usage?;
    string createdTime?;
    string lastUpdatedTime?;
    string md5?;
    string definitionUrl?;
};

public type ServiceArtifact record {|
    string name;
    string description = "";
    string version = "_";
    string serviceKey;
    string serviceUrl;
    DefinitionType definitionType;
    SecurityType securityType = "BASIC";
    boolean mutualSSLEnabled = false;
    int usage = 1;
    string createdTime;
    string lastUpdatedTime;
    string md5;
    string definitionUrl;
    string definitionFileContent = "";
|};

public enum DefinitionType {
    OAS2,
    OAS3,
    WSDL1,
    WSDL2,
    GRAPHQL_SDL,
    ASYNC_API
};

public enum SecurityType {
    BASIC,
    DIGEST,
    OAUTH2,
    X509,
    API_KEY,
    NONE
};
