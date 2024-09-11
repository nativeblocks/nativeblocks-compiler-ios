import SwiftSyntax
import SwiftSyntaxBuilder

enum NativeProviderGenerator {
    public static func generateBlockProvider(prefix: String, blocks: [NativeBlock]) throws -> SourceFileSyntax {
        return try SourceFileSyntax {
            """
            import Nativeblocks
            """
            try ClassDeclSyntax("public class \(raw: prefix)BlockProvider") {
                try FunctionDeclSyntax("public static func provideBlocks()") {
                    for block in blocks {
                        """
                        NativeblocksManager.getInstance().provideBlock(blockKeyType: "\(raw: block.keyType)", block: \(raw: block.declName)Block())
                        """
                    }
                }
            }
        }
    }
    
    public static func generateActionProvider(prefix: String, actions: [NativeAction]) throws -> SourceFileSyntax {
        return try SourceFileSyntax {
            """
            import Nativeblocks
            """
            try ClassDeclSyntax("public class \(raw: prefix)ActionProvider") {
                let arguments = actions.map { action in
                    """
                    \(refinActionArgumentName(name: action.declName)) : \(action.declName)
                    """
                }.joined(separator: " ,")
                
                try FunctionDeclSyntax("public static func provideActions(\(raw: arguments))") {
                    for action in actions {
                        """
                        NativeblocksManager.getInstance().provideAction(actionKeyType: "\(raw: action.keyType)", action: \(raw: action.declName)Action(action: \(raw: refinActionArgumentName(name: action.declName))))
                        """
                    }
                }
            }
        }
    }
    
    static func refinActionArgumentName(name: String) -> String {
        let firstCharacter = name.prefix(1).lowercased()
        let remainingCharacters = name.dropFirst()
        return firstCharacter + remainingCharacters
    }
}
