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
import ballerinax/wso2.apim.catalog as _;
import ballerina/file;

string ballerinaTestDirPath = file:getCurrentDir();
string resourcesPath = string `${check file:parentPath(ballerinaTestDirPath)}/test-resources/sample_project_8/resources`;
string clientStorepath = string `${resourcesPath}/clientKeyStore.p12`;
string clientStorePassword = "password";
string clientTrustStorePath = string `${resourcesPath}/clientTrustStore.p12`;
string clientTrustStorePassword = "password";

listener http:Listener l = check new (9080, {
    secureSocket: {
        key: {
            path: clientStorepath,
            password: clientStorePassword
        }, 
        mutualSsl: {
            cert: {
                    path: clientTrustStorePath,
                    password: clientTrustStorePassword
            }
        }
    }
});

listener http:Listener l2 = check new (9081, {
    secureSocket: {
        key: {
            path: clientStorepath,
            password: clientStorePassword
        }, 
        mutualSsl: {
            verifyClient: "OPTIONAL",
            cert: {
                path: clientTrustStorePath,
                password: clientTrustStorePassword
            }
        }
    }
});

listener http:Listener l3 = check new (9082, {
    secureSocket: {
        key: {
             path: clientStorepath,
            password: clientStorePassword
        }, 
        mutualSsl: {
            verifyClient: "REQUIRE",
            cert: {
                path: clientTrustStorePath,
                password: clientTrustStorePassword
            }
        }
    }
});

@http:ServiceConfig {
    auth: [],
    host: "www.example.com"
}
service /sales0 on l {

}

@http:ServiceConfig {
    auth: [],
    host: "www.example.com"
}
service /sales0 on l2 {

}

@http:ServiceConfig {
    auth: [],
    host: "www.example.com"
}
service /sales0 on l3 {

}
