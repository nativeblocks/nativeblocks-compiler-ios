import Foundation
import SwiftParser
import SwiftSyntax

class NativeBlockVisitor: SyntaxVisitor {
    var nativeBlocks: [NativeItem] = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let attributes = node.attributes
        if let attribute = findAttribute(name: "NativeBlock", from: attributes) {
            let structName = node.name.text
            let keyType = getStringValue(name: "keyType", from: attribute)
            let name = getStringValue(name: "name", from: attribute)
            let description = getStringValue(name: "description", from: attribute)
            nativeBlocks.append(NativeBlock(declName: structName, name: name!, keyType: keyType!, description: description!, syntax: node))
        }
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let attributes = node.attributes
        if let attribute = findAttribute(name: "NativeAction", from: attributes) {
            let structName = node.name.text
            let keyType = getStringValue(name: "keyType", from: attribute)
            let name = getStringValue(name: "name", from: attribute)
            let description = getStringValue(name: "description", from: attribute)
            nativeBlocks.append(NativeAction(declName: structName, name: name!, keyType: keyType!, description: description!, syntax: node))
        }
        return .skipChildren
    }

    private func findAttribute(name: String, from attributes: AttributeListSyntax) -> AttributeSyntax? {
        for attribute in attributes {
            if let attributeIdentifier = attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self),
               attributeIdentifier.name.text == name
            {
                return attribute.as(AttributeSyntax.self)
            }
        }
        return nil
    }

    private func getStringValue(name: String, from attribute: AttributeSyntax) -> String? {
        var value: String? = nil
        attribute.arguments?.as(LabeledExprListSyntax.self)?.forEach { arg in
            if arg.label?.text == name {
                value = arg.expression.as(StringLiteralExprSyntax.self)?.segments.as(StringLiteralSegmentListSyntax.self)?.first?.as(StringSegmentSyntax.self)?.content.text
            }
        }
        return value
    }
}
