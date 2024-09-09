import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum NativeblocksCompilerDiagnostic: String, DiagnosticMessage {
    case notAStruct
    case notAClass
    case singleVariableLimit
    case blockIndexParamLimit
    case functionTypeError
    case eventTypeMisMachParamCount
    case premitiveTypeSupported
    case eventDataMissing
    case requiredNativeActionFunction
    case requiredNativeActionFunctionParameter

    var severity: DiagnosticSeverity { return .error }

    var message: String {
        switch self {
        case .notAStruct:
            return "Can only be used with structs."
        case .notAClass:
            return "Can only be used with classes."
        case .singleVariableLimit:
            return "Property wrapper applies to a single variable."
        case .blockIndexParamLimit:
            return "Requires one 'BlockIndex' parameter."
        case .functionTypeError:
            return "Must be a function."
        case .eventTypeMisMachParamCount:
            return "Requires parameters matching 'dataBinding' count."
        case .premitiveTypeSupported:
            return "Primitive type supported."
        case .eventDataMissing:
            return "For binding, define '@NativeBlockData' with the same type and name as the bound value."
        case .requiredNativeActionFunction:
            return "Requires one '@NativeActionFunction' anotated function."
        case .requiredNativeActionFunctionParameter:
            return "'@NativeActionFunction' Requires one parameter struct anotated with '@NativeActionParameter'"
        }

    }

    var diagnosticID: MessageID {
        MessageID(domain: "NativeblocksCompilerMacros", id: rawValue)
    }
}
