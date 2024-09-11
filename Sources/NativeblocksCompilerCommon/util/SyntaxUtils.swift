import SwiftSyntax

public struct SyntaxUtils {
    static func extractAttribute(for type: String, from attributes: AttributeListSyntax) -> AttributeSyntax? {
        for attribute in attributes {
            if let attr = attribute.as(AttributeSyntax.self),
                attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == type
            {
                return attr
            }
        }
        return nil
    }

    static func extractDescription(from attribute: AttributeSyntax) -> String? {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else { return nil }
        for argument in arguments where argument.label?.text == "description" {
            if let segments = argument.expression.as(StringLiteralExprSyntax.self)?.segments.as(StringLiteralSegmentListSyntax.self) {
                return segments.first?.as(StringSegmentSyntax.self)?.content.text
            }
        }
        return nil
    }

    static func extractDataBinding(from attribute: AttributeSyntax) -> [String]? {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else { return nil }
        for argument in arguments where argument.label?.text == "dataBinding" {
            if let arrayElements = argument.expression.as(ArrayExprSyntax.self)?.elements {
                return arrayElements.compactMap { element in
                    element.expression.as(StringLiteralExprSyntax.self)?.segments.compactMap { segment in
                        segment.as(StringSegmentSyntax.self)?.content.text
                    }.joined()
                }
            }
        }
        return nil
    }

    static func extractThen(from attribute: AttributeSyntax) -> String? {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }

        for argument in arguments where argument.label?.text == "then" {
            if let declName = argument.expression.as(MemberAccessExprSyntax.self)?.declName.as(DeclReferenceExprSyntax.self) {
                return declName.baseName.text
            }
        }
        return nil
    }

    static func extractDefaultValue(from initializer: InitializerClauseSyntax?) -> String {
        guard let initializer = initializer?.value else { return "" }
        if let stringLiteral = initializer.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text {
            return "\"\(stringLiteral)\""
        } else if let intLiteral = initializer.as(IntegerLiteralExprSyntax.self)?.literal.text {
            return intLiteral
        } else if let floatLiteral = initializer.as(FloatLiteralExprSyntax.self)?.literal.text {
            return floatLiteral
        } else if let booleanLiteral = initializer.as(BooleanLiteralExprSyntax.self)?.description {
            return booleanLiteral
        } else if initializer.as(NilLiteralExprSyntax.self) != nil {
            return "nil"
        }
        return ""
    }

    static func isPrimitiveTypeSupported(_ type: String) -> Bool {
        let supportedTypes: Set<String> = [
            "STRING", "BOOL", "INT", "INT64", "INT32", "INT16", "INT8", "UINT", "UINT64",
            "UINT32", "UINT16", "UINT8", "FLOAT", "FLOAT80", "FLOAT64", "FLOAT32",
            "FLOAT16", "CGFLOAT", "DOUBLE",
        ]
        return supportedTypes.contains(type.uppercased())
    }

    static func getType(from varDecl: VariableDeclSyntax, blockTypes: [String]) -> (String, AttributeSyntax)? {
        for type in blockTypes {
            if let attribute = extractAttribute(for: type, from: varDecl.attributes) {
                return (type, attribute)
            }
        }
        return nil
    }

    static func getType(from varDecl: VariableDeclSyntax) -> (String, AttributeSyntax)? {
        let attributes = varDecl.attributes
        for attribute in attributes {
            if let attr = attribute.as(AttributeSyntax.self) {
                let name = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text
                if name != nil {
                    return (name!, attr)
                }
            }
        }
        return nil
    }

    static func validateEventParams(_ function: FunctionTypeSyntax?, expectedCount: Int, binding: VariableDeclSyntax) -> Bool {
        let parameters = function?.parameters ?? []
        return parameters.count == expectedCount
    }

    static func extractFunctionFromType(_ type: TypeSyntax?) -> (FunctionTypeSyntax?, Bool) {
        if let function = type?.as(FunctionTypeSyntax.self) {
            return (function, false)
        } else if let optionalFunction = type?.as(OptionalTypeSyntax.self)?.wrappedType.as(FunctionTypeSyntax.self) {
            return (optionalFunction, true)
        }
        return (nil, false)
    }
}