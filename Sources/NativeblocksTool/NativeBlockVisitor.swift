import Foundation
import SwiftParser
import SwiftSyntax

class NativeBlockVisitor: SyntaxVisitor {
   var nativeBlocks: [NativeItem] = []

   override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
       let attributes = node.attributes
       if hasNativeBlockAttribute(attributes) {
           let structName = node.name.text
           nativeBlocks.append(NativeBlock( name:structName,syntax:node))
       }
       return .skipChildren
   }
    
   override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let attributes = node.attributes
        if hasNativeActionAttribute(attributes) {
            let structName = node.name.text
            nativeBlocks.append(NativeAction(name:structName,syntax:node))
        }
        return .skipChildren
    }

   private func hasNativeBlockAttribute(_ attributes: AttributeListSyntax) -> Bool {
       for attribute in attributes {
           if let attributeIdentifier = attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self),
              attributeIdentifier.name.text == "NativeBlock"
           {
               return true
           }
       }
       return false
   }
    
    private func hasNativeActionAttribute(_ attributes: AttributeListSyntax) -> Bool {
        for attribute in attributes {
            if let attributeIdentifier = attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self),
               attributeIdentifier.name.text == "NativeAction"
            {
                return true
            }
        }
        return false
    }
}
