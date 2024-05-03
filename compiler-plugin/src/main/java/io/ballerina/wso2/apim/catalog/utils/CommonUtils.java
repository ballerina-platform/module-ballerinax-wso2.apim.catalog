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

package io.ballerina.wso2.apim.catalog.utils;

import io.ballerina.compiler.syntax.tree.AbstractNodeFactory;
import io.ballerina.compiler.syntax.tree.AnnotationNode;
import io.ballerina.compiler.syntax.tree.ExpressionNode;
import io.ballerina.compiler.syntax.tree.IdentifierToken;
import io.ballerina.compiler.syntax.tree.ImportDeclarationNode;
import io.ballerina.compiler.syntax.tree.ImportOrgNameNode;
import io.ballerina.compiler.syntax.tree.ImportPrefixNode;
import io.ballerina.compiler.syntax.tree.MappingConstructorExpressionNode;
import io.ballerina.compiler.syntax.tree.MappingFieldNode;
import io.ballerina.compiler.syntax.tree.MetadataNode;
import io.ballerina.compiler.syntax.tree.Minutiae;
import io.ballerina.compiler.syntax.tree.MinutiaeList;
import io.ballerina.compiler.syntax.tree.NodeFactory;
import io.ballerina.compiler.syntax.tree.NodeList;
import io.ballerina.compiler.syntax.tree.NodeParser;
import io.ballerina.compiler.syntax.tree.QualifiedNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.compiler.syntax.tree.SimpleNameReferenceNode;
import io.ballerina.compiler.syntax.tree.SpecificFieldNode;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.compiler.syntax.tree.Token;
import io.ballerina.projects.plugins.SourceModifierContext;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import java.nio.charset.Charset;
import java.util.Base64;

public class CommonUtils {
    public static final MinutiaeList SINGLE_WS_MINUTIAE = getSingleWSMinutiae();

    public static MetadataNode getMetadataNode(ServiceDeclarationNode serviceNode) {
        return serviceNode.metadata().orElseGet(() -> {
            NodeList<AnnotationNode> annotations = NodeFactory.createNodeList();
            return NodeFactory.createMetadataNode(null, annotations);
        });
    }
    public static boolean diagnosticContainsErrors(SourceModifierContext context) {
        return context.compilation().diagnosticResult()
                .diagnostics().stream()
                .anyMatch(d -> DiagnosticSeverity.ERROR.equals(d.diagnosticInfo().severity()));
    }

    public static AnnotationNode getServiceCatalogConfigAnnotation(String openApiDefinition) {
        String configIdentifierString = Constants.CATALOG + SyntaxKind.COLON_TOKEN.stringValue() +
                Constants.SERVICE_CATALOG_METADATA_ANNOTATION_IDENTIFIER;
        IdentifierToken identifierToken = NodeFactory.createIdentifierToken(configIdentifierString);
        Token atToken = NodeFactory.createToken(SyntaxKind.AT_TOKEN);
        SimpleNameReferenceNode nameReferenceNode = NodeFactory.createSimpleNameReferenceNode(identifierToken);
        MappingConstructorExpressionNode annotValue = getAnnotationExpression(openApiDefinition);
        return NodeFactory.createAnnotationNode(atToken, nameReferenceNode, annotValue);
    }

    public static MappingConstructorExpressionNode getAnnotationExpression(String openApiDefinition) {
        Token openBraceToken = NodeFactory.createToken(SyntaxKind.OPEN_BRACE_TOKEN);
        Token closeBraceToken = NodeFactory.createToken(SyntaxKind.CLOSE_BRACE_TOKEN);
        SpecificFieldNode specificFieldNode = createOpenApiDefinitionField(openApiDefinition);
        SeparatedNodeList<MappingFieldNode> separatedNodeList = NodeFactory.createSeparatedNodeList(specificFieldNode);
        return NodeFactory.createMappingConstructorExpressionNode(openBraceToken, separatedNodeList, closeBraceToken);
    }

    public static SpecificFieldNode createOpenApiDefinitionField(String openApiDefinition) {
        IdentifierToken fieldName = AbstractNodeFactory.createIdentifierToken(Constants.OPEN_API_DEFINITION_FIELD);
        Token colonToken = AbstractNodeFactory.createToken(SyntaxKind.COLON_TOKEN);
        String encodedValue = Base64.getEncoder().encodeToString(openApiDefinition.getBytes(Charset.defaultCharset()));
        ExpressionNode expressionNode = NodeParser.parseExpression(
                String.format("base64 `%s`.cloneReadOnly()", encodedValue));
        return NodeFactory.createSpecificFieldNode(null, fieldName, colonToken, expressionNode);
    }

    public static boolean isServiceCatalogConfigAnnotationAvailable(AnnotationNode annotationNode) {
        if (!(annotationNode.annotReference() instanceof QualifiedNameReferenceNode)) {
            return false;
        }
        QualifiedNameReferenceNode referenceNode = ((QualifiedNameReferenceNode) annotationNode.annotReference());
        if (!Constants.CATALOG.equals(referenceNode.modulePrefix().text())) {
            return false;
        }
        return Constants.SERVICE_CATALOG_METADATA_ANNOTATION_IDENTIFIER.equals(referenceNode.identifier().text());
    }

    public static ImportDeclarationNode createImportDeclarationNodeForModule() {
        Token importKeyword = AbstractNodeFactory.createIdentifierToken(Constants.IMPORT, SINGLE_WS_MINUTIAE,
                SINGLE_WS_MINUTIAE);
        Token slashToken = NodeFactory.createToken(SyntaxKind.SLASH_TOKEN);
        Token orgNameToken = AbstractNodeFactory.createIdentifierToken(Constants.MODULE_NAME);
        ImportOrgNameNode importOrgNameNode = NodeFactory.createImportOrgNameNode(orgNameToken, slashToken);
        Token moduleNameToken = AbstractNodeFactory.createIdentifierToken(Constants.SERVICE_CATALOG_PACKAGE_NAME);
        SeparatedNodeList<IdentifierToken> moduleNodeList = AbstractNodeFactory
                .createSeparatedNodeList(moduleNameToken);
        ImportPrefixNode prefix = NodeFactory.createImportPrefixNode(
                AbstractNodeFactory.createIdentifierToken(Constants.AS, SINGLE_WS_MINUTIAE, SINGLE_WS_MINUTIAE),
                NodeFactory.createIdentifierToken(Constants.CATALOG));
        Token semicolon = NodeFactory.createToken(SyntaxKind.SEMICOLON_TOKEN);
        return NodeFactory.createImportDeclarationNode(importKeyword, importOrgNameNode,
                moduleNodeList, prefix, semicolon);
    }

    private static MinutiaeList getSingleWSMinutiae() {
        Minutiae whitespace = AbstractNodeFactory.createWhitespaceMinutiae(" ");
        MinutiaeList leading = AbstractNodeFactory.createMinutiaeList(whitespace);
        return leading;
    }
}
