import ballerina/http;
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

import ballerinax/wso2.apim.catalog as _;
import ballerina/openapi;

@http:ServiceConfig {
    host: "www.example.com"
}
service /sales0 on new http:Listener(9500) {
}

@http:ServiceConfig {
    host: "localhost"
}
service /sales0 on new http:Listener(9501) {
}

@http:ServiceConfig {
    host: ""
}
service /sales0 on new http:Listener(9502) {
}

@openapi:ServiceInfo {
    'version: "1.0.0"
}
service /sales0 on new http:Listener(9503) {
}

@openapi:ServiceInfo {
    'version: "4.1.2"
}
@http:ServiceConfig {
    host: "www.example.com"
}
service /sales0 on new http:Listener(9504) {
}

// This test case disable due to issue:- https://github.com/ballerina-platform/ballerina-library/issues/6477
// @http:ServiceConfig {
//     host: "www.example.com"
// }
// @openapi:ServiceInfo {
//     'version: ()
// }
// service /sales0 on new http:Listener(9505) {
// }

@openapi:ServiceInfo {
    'version: ""
}
service /sales0 on new http:Listener(9506) {
}
