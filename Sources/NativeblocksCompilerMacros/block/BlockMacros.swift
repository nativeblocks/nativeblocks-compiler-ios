import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NativeBlockMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            let structError = Diagnostic(
                node: declaration,
                message: NativeblocksCompilerDiagnostic.notAStruct
            )
            context.diagnose(structError)
            return []
        }

        let (variables, diagnostic) = BlockExtractor.extractVariable(from: structDecl)

        for error in diagnostic {
            context.diagnose(error)
        }

        let metaData = variables.compactMap { $0 as? Data }
        let metaProp = variables.compactMap { $0 as? Property }
        let metaEvent = variables.compactMap { $0 as? Event }
        let metaSlot = variables.compactMap { $0 as? Slot }

        let newStructDecl = try BlockCreator.create(
            structName: structDecl.name.text,
            metaData: metaData,
            metaProp: metaProp,
            metaEvent: metaEvent,
            metaSlot: metaSlot
        )
        return [DeclSyntax(newStructDecl)]
    }
}

public struct NativeBlockDataMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct NativeBlockPropMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct NativeBlockEventMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct NativeBlockSlotMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}
