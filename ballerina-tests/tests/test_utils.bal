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

import ballerina/file;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/mime;
import ballerina/os;
import ballerina/test;

string sep = file:pathSeparator;
string currentDir = file:getCurrentDir();
string rootDir = check file:parentPath(currentDir);
string ballerinaTestDir = string `${rootDir}${sep}ballerina-tests${sep}tests`;
string bal = string `${rootDir}${sep}target${sep}ballerina-runtime${sep}bin${sep}bal`;

function runOSCommand(string projName, string projPath, string configFilePath) returns error? {
    os:Process|os:Error process = os:exec({
        value: string `${bal}`,
        arguments: ["run", string `${projPath}`]
    },
        BAL_CONFIG_FILES = configFilePath
    );

    if process is error {
        log:printInfo(
            string `Error while exec run command in :- ${projName}, e = ${process.message()}`);
        return process;
    }

    int|os:Error waitForExit = process.waitForExit();

    if waitForExit is os:Error {
        log:printInfo(
            string `Error while waiting for exit in :- ${projName}, e = ${waitForExit.message()}`);
        return waitForExit;
    } else {
        string output = check string:fromBytes(check process.output(io:stderr));
        if waitForExit != 0 {
            return error(string `${output}`);
        }
    }
}

function getProjName(int i) returns string {
    return string `test_sample_${i}`;
}

function getProjPath(int i) returns string {
    return string `${rootDir}${sep}test-resources${sep}sample_project_${i}`;
}

function getConfigFilePath(int i) returns string {
    return string `${currentDir}${sep}tests${sep}configs${sep}sample_project_${i}${sep}Config.toml`;
}

function traverseMultiPartRequest(http:Request req) returns ServiceSchema|error {
    mime:Entity[] bodyParts = check req.getBodyParts();
    Service serviceMetadata = check (check bodyParts[0].getJson()).cloneWithType();
    string inlineContent = check bodyParts[1].getText();
    return {
        serviceMetadata,
        inlineContent
    };
}

function returnDummyResponse(string message = "Return 500 Status code after completing the task") 
            returns http:InternalServerError {
    // Return error to terminate the test process
    return {
        body: {
            message
        }
    };
}

function readAndValidateArtifacts(string file, int index, string basePathPrefix = "/sales") {
    json|error artifactJson = io:fileReadJson(string `${artifactPath}/${file}`);

    if artifactJson is error {
        test:assertFail(string `Error while reading the ${file}`);
    }

    ServiceSchema[]|error artifacts = artifactJson.cloneWithType();
    if artifacts is error {
        test:assertFail(string `Error while cloning the artifacts in ${file}`);
    }

    validateArtifacts(artifacts, index, basePathPrefix);
}

function validateArtifacts(ServiceSchema[] artifacts, int index, string basePathPrefix) {
    string assertPath = string `${ballerinaTestDir}${sep}asserts`;
    string assertFile = string `assert_${index}.json`;
    json|error assertJson = io:fileReadJson(string `${assertPath}/${assertFile}`);

    if assertJson is error {
        test:assertFail(string `Error while reading the ${assertFile}`);
    }

    map<ServiceSchema>|error assertArtifacts = assertJson.cloneWithType();
    if assertArtifacts is error {
        test:assertFail(
            string `Error while cloning the assertArtifacts in ${assertFile}, error = ${assertArtifacts.message()}, detail = ${assertArtifacts.detail().toBalString()}`
        );
    }
    
    foreach ServiceSchema schema in artifacts {
        string serviceKey = <string> (schema.serviceMetadata.serviceKey);
        if !assertArtifacts.hasKey(serviceKey) {
            test:assertFail(string `Service key ${serviceKey} not found in assert file ${assertFile}`);
        }

        ServiceSchema assertSchema = <ServiceSchema> assertArtifacts[serviceKey];
        if isNameStartWithSamePrefix(assertSchema.serviceMetadata.name, 
                schema.serviceMetadata.name, basePathPrefix) {
            assertSchema.serviceMetadata.name = schema.serviceMetadata.name;
            test:assertEquals(assertSchema, schema);
        } else {
            test:assertFail(string `Service name ${schema.serviceMetadata.name} not start with ${basePathPrefix}`);
        }
    }
}

function isNameStartWithSamePrefix(string assertSchemaName, string schemaName, string basePathPrefix) returns boolean {
    return assertSchemaName.startsWith(basePathPrefix) && schemaName.startsWith(basePathPrefix);
}
