import SwiftSyntax
import SwiftSyntaxBuilder

enum NativeProviderGenerator {
    public static func generateProvider(prefix: String, blocks: [NativeBlock], actions: [NativeAction]) throws -> SourceFileSyntax {
        return try SourceFileSyntax {
            try ClassDeclSyntax("public class \(raw: prefix)BlockProvider") {
                try FunctionDeclSyntax("public static func provideBlocks()") {
                    for block in blocks {
                        """
                        NativeblocksManager.getInstance().provideBlock(blockKeyType: "\(raw: block.name)", block: \(raw: block.name)Block())
                        """
                    }
                }

                try FunctionDeclSyntax("public static func provideActions()") {
                    for action in actions {
                        """
                        NativeblocksManager.getInstance().provideAction(actionKeyType: "\(raw: action.name)", action: \(raw: action.name)Action(action: action))
                        """
                    }
                }
            }
        }
    }
}
