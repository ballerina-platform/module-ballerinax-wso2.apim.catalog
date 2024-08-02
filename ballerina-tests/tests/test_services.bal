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

import ballerina/test;

@test:Config{dataProvider: testdataGen}
function testSingleService(int index) returns error? {
    string file = string `artifacts_${index}.json`;
    
    // In here error will be the expected behaviour since currently it is the only way to terminate the processes.
    // Currently ballerina/os module does not support a way to terminate the processes.
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(file, index);
}

@test:Config{}
function testSingleServiceWithConnectionRefuse() returns error? {
    int index = 9;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message().includes("Something wrong with the connection"));
}

@test:Config{}
function testSingleServiceWithTokenCallfailure() returns error? {
    int index = 10;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message().includes("Failed to call the token endpoint"));
}

@test:Config{}
function testSingleUnauthorizedService() returns error? {
    int index = 11;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message().includes("Unauthorized"));
}

@test:Config{}
function testSingleServiceWithBasepathAsSlash() returns error? {
    int index = 7;
    string file = string `artifacts_${index}.json`;
    error? result = runOSCommand(getProjName(index), getProjPath(index), getConfigFilePath(index));
    test:assertTrue(result is error);
    readAndValidateArtifacts(file, index, "/");
}

function testdataGen() returns int[][] {
    return [[0], [1], [2], [3], [4], [5], [6], [8]];
}
