import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import _NativeblocksCompilerCommon

public struct NativeActionMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDecl = declaration.as(ClassDeclSyntax.self) else {
            let structError = Diagnostic(
                node: declaration,
                message: NativeblocksCompilerDiagnostic.notAClass
            )
            context.diagnose(structError)
            return []
        }

        let (variables, diagnostic) = ActionExtractor.extractVariable(from: structDecl)

        for error in diagnostic {
            context.diagnose(error)
        }

        let metaData = variables.compactMap { $0 as? DataNativeMeta }
        let metaProp = variables.compactMap { $0 as? PropertyNativeMeta }
        let metaEvent = variables.compactMap { $0 as? EventNativeMeta }
        let actionInfo = variables.compactMap { $0 as? ActionNativeMeta }.first

        let newStructDecl = try ActionCreator.create(
            structName: structDecl.name.text,
            actionInfo: actionInfo,
            metaData: metaData,
            metaProp: metaProp,
            metaEvent: metaEvent
        )
        return [DeclSyntax(newStructDecl)]
    }
}

public struct NativeActionFunctionMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct NativeActionParameterMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct NativeActionDataMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct NativeActionPropMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct NativeActionEventMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}
