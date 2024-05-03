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

service /sales0/base on new http:Listener(9200) {
    
    resource function get orders() {
        
    }

    resource function post orders() {
        
    }
}

// TODO: Create and add a issue for the Graphql.
// service /sales0 on new graphql:Listener(9201) {
//     resource function get orders() returns string[] {
//         return [];
//     }

//     resource function get items() returns int[] {
//         return [];
//     }
// }

service /sales0 on new http:Listener(9202) {
    resource function get orders() {
        
    }

    resource function post orders() {
        
    }
}
