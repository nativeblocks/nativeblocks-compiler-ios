import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder

public struct ActionExtractor {
    static let NativeActionDataType = "NativeActionData"
    static let NativeActionPropType = "NativeActionProp"
    static let NativeActionEventType = "NativeActionEvent"
    static let NativeActionFunctionType = "NativeActionFunction"
    static let NativeActionParameterType = "NativeActionParameter"

    public static func extractVariable(from structDecl: ClassDeclSyntax) -> ([NativeMeta], [Diagnostic]) {
        var meta: [NativeMeta] = []
        var errors: [Diagnostic] = []
        var position = 0

        let (actionInfo, parameters, actionDiagnostic) = extractActionInfo(from: structDecl)

        if actionInfo == nil {
            return ([], actionDiagnostic)
        } else {
            meta.append(actionInfo!)
        }

        for parameter in parameters {
            position += 1

            guard let (type, _) = SyntaxUtils.getType(from: parameter)
            else {
                continue
            }
            switch type {
            case NativeActionDataType:
                do {
                    guard let (block, blockErrors) = extractDataAction(from: parameter, startPosition: position)
                    else {
                        continue
                    }
                    position = block.last?.position ?? position
                    errors.append(contentsOf: blockErrors)
                    meta.append(contentsOf: block)
                }
            case NativeActionPropType:
                do {
                    guard let (block, blockErrors) = extractPropAction(from: parameter, startPosition: position)
                    else {
                        continue
                    }
                    position = block.last?.position ?? position
                    errors.append(contentsOf: blockErrors)
                    meta.append(contentsOf: block)
                }
            case NativeActionEventType:
                do {
                    guard let (block, blockErrors) = extractEventAction(from: parameter, startPosition: position)
                    else {
                        continue
                    }
                    position = block.last?.position ?? position
                    errors.append(contentsOf: blockErrors)
                    meta.append(contentsOf: block)
                }
            default:
                continue
            }
        }

        let dataActions = meta.compactMap { $0 as? DataNativeMeta }
        let eventActions = meta.compactMap { $0 as? EventNativeMeta }

        for event in eventActions {
            for binding in event.dataBinding {
                if dataActions.first(where: { data in data.key == binding }) == nil {
                    errors.append(
                        Diagnostic(
                            node: event.valriable!,
                            message: NativeblocksCompilerDiagnostic.eventDataMissing
                        ))
                }
            }
        }

        let eventGroupByThen = Dictionary(grouping: eventActions, by: { $0.then }).filter { $0.value.count > 1 }

        for eventGroup in eventGroupByThen {
            for event in eventGroup.value {
                errors.append(
                    Diagnostic(
                        node: event.valriable!,
                        message: NativeblocksCompilerDiagnostic.eventDistinctThen
                    ))
            }
        }

        return (meta, errors)
    }

    private static func extractActionInfo(from classDecl: ClassDeclSyntax) -> (
        ActionNativeMeta?, [VariableDeclSyntax], [Diagnostic]
    ) {
        var parameterClass = ""
        var functionName = ""
        var functionParamName = ""
        var parameters: [VariableDeclSyntax] = []
        var functionParams: [FunctionParameterSyntax] = []
        var diagnostic: [Diagnostic] = []
        var isAsync = false

        let functions = classDecl.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }.filter { function in
            function.attributes.filter { element in
                element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == NativeActionFunctionType
            }.count > 0
        }

        if functions.count != 1 {
            diagnostic.append(
                Diagnostic(
                    node: classDecl,
                    message: NativeblocksCompilerDiagnostic.requiredNativeActionFunction
                ))
        }

        isAsync = functions.first?.signature.effectSpecifiers?.asyncSpecifier?.text == "async"
        
        let declThrows =  functions.first?.signature.effectSpecifiers?.throwsSpecifier
        let haveThrows =  declThrows?.text == "throws"
        
        if haveThrows {
            diagnostic.append(
                Diagnostic(
                    node: classDecl,
                    message: NativeblocksCompilerDiagnostic.requiredNativeActionFunctionParameter
                ))
        }

        functionName = functions.first?.name.text ?? ""
        functionParams = functions.first?.signature.parameterClause.parameters.compactMap { $0.as(FunctionParameterSyntax.self) } ?? []

        functionParamName = functionParams.first?.firstName.text ?? ""

        if !functionParams.isEmpty {
            let structs = classDecl.memberBlock.members.compactMap { $0.decl.as(StructDeclSyntax.self) }.filter { structDecl in
                structDecl.attributes.filter { element in
                    element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == NativeActionParameterType
                }.count > 0
            }
            parameterClass = structs.first?.name.text ?? ""
            parameters = structs.first?.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) } ?? []

            if functionParams.count != 1 || structs.count != 1 {
                diagnostic.append(
                    Diagnostic(
                        node: classDecl,
                        message: NativeblocksCompilerDiagnostic.requiredNativeActionFunctionParameter
                    ))
            }
        }

        return !functionName.isEmpty
            ? (
                ActionNativeMeta(
                    parameterClass: parameterClass,
                    functionName: functionName,
                    functionParamName: functionParamName,
                    isAsync: isAsync
                ),
                parameters,
                diagnostic
            )
            : (nil, parameters, diagnostic)
    }

    private static func extractDataAction(from varDecl: VariableDeclSyntax, startPosition: Int)
        -> ([DataNativeMeta], [Diagnostic])?
    {
        var position = startPosition
        let attributes = varDecl.attributes
        var description = "" as String?
        var blockAttribute: AttributeSyntax?
        var diagnostic: [Diagnostic] = []

        blockAttribute = SyntaxUtils.extractAttribute(for: NativeActionDataType, from: attributes)

        guard blockAttribute != nil else { return nil }

        description = SyntaxUtils.extractDescription(from: blockAttribute!) ?? ""

        return (
            varDecl.bindings.compactMap { binding in
                position += 1
                let key = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""
                let type = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(IdentifierTypeSyntax.self)?.name.text ?? ""

                if !SyntaxUtils.isPrimitiveTypeSupported(type) {
                    diagnostic.append(
                        Diagnostic(
                            node: blockAttribute!,
                            message: NativeblocksCompilerDiagnostic.premitiveTypeSupported
                        ))
                }

                return !key.isEmpty && !type.isEmpty
                    ? DataNativeMeta(
                        position: position,
                        key: key,
                        type: type,
                        description: description ?? "",
                        block: blockAttribute,
                        valriable: binding
                    ) : nil
            }, diagnostic
        )
    }

    private static func extractPropAction(from varDecl: VariableDeclSyntax, startPosition: Int)
        -> ([PropertyNativeMeta], [Diagnostic])?
    {
        var position = startPosition
        let attributes = varDecl.attributes
        var description = ""
        var blockAttribute: AttributeSyntax?
        var diagnostic: [Diagnostic] = []
        var valuePicker = ""
        var valuePickerGroup = ""
        var valuePickerOptions: [ValuePickerOption] = []

        blockAttribute = SyntaxUtils.extractAttribute(for: NativeActionPropType, from: attributes)
        guard blockAttribute != nil else { return nil }
        description = SyntaxUtils.extractDescription(from: blockAttribute!) ?? ""
        valuePicker = SyntaxUtils.extractValuePicker(from: blockAttribute!) ?? "TEXT_INPUT"
        valuePickerGroup = SyntaxUtils.extractValuePickerGroup(from: blockAttribute!) ?? "General"

        valuePickerOptions = SyntaxUtils.extractvaluePickerOptions(from: blockAttribute!) ?? []

        if varDecl.bindings.count > 1 {
            diagnostic.append(
                Diagnostic(
                    node: blockAttribute!,
                    message: NativeblocksCompilerDiagnostic.singleVariableLimit
                ))
        }

        return (
            varDecl.bindings.compactMap { binding in
                position += 1
                let key = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""
                let type = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(IdentifierTypeSyntax.self)?.name.text ?? ""
                let value = SyntaxUtils.extractDefaultValue(from: binding.initializer)

                if !SyntaxUtils.isPrimitiveTypeSupported(type) {
                    diagnostic.append(
                        Diagnostic(
                            node: blockAttribute!,
                            message: NativeblocksCompilerDiagnostic.premitiveTypeSupported
                        ))
                }

                return !key.isEmpty && !type.isEmpty
                    ? PropertyNativeMeta(
                        position: position,
                        key: key,
                        value: value,
                        type: type,
                        description: description,
                        valuePicker: valuePicker,
                        valuePickerOptions: valuePickerOptions,
                        valuePickerGroup: valuePickerGroup,
                        block: blockAttribute,
                        valriable: binding
                    ) : nil
            }, diagnostic
        )
    }

    private static func extractEventAction(
        from varDecl: VariableDeclSyntax, startPosition: Int
    )
        -> ([EventNativeMeta], [Diagnostic])?
    {
        var position = startPosition
        let attributes = varDecl.attributes
        var description = ""
        var dataBinding: [String] = []
        var isOptinalFunction = false
        var then: String?
        var blockAttribute: AttributeSyntax?
        var diagnostic: [Diagnostic] = []

        blockAttribute = SyntaxUtils.extractAttribute(for: NativeActionEventType, from: attributes)
        guard blockAttribute != nil else { return nil }
        description = SyntaxUtils.extractDescription(from: blockAttribute!) ?? ""
        dataBinding = SyntaxUtils.extractDataBinding(from: blockAttribute!) ?? []
        then = SyntaxUtils.extractThen(from: blockAttribute!)

        if varDecl.bindings.count > 1 {
            diagnostic.append(
                Diagnostic(
                    node: blockAttribute!,
                    message: NativeblocksCompilerDiagnostic.singleVariableLimit
                ))
        }

        return (
            varDecl.bindings.compactMap { binding in
                position += 1
                let event = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""

                var function = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(FunctionTypeSyntax.self)

                if function == nil {
                    function = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type.as(OptionalTypeSyntax.self)?.wrappedType.as(
                        TupleTypeSyntax.self)?.elements.as(TupleTypeElementListSyntax.self)?.first?.type.as(FunctionTypeSyntax.self)
                    isOptinalFunction = function != nil
                }
                let parameters = function?.parameters ?? []

                if function == nil {
                    diagnostic.append(
                        Diagnostic(
                            node: binding,
                            message: NativeblocksCompilerDiagnostic.functionTypeError
                        ))
                }

                if parameters.count != dataBinding.count {
                    diagnostic.append(
                        Diagnostic(
                            node: binding,
                            message: NativeblocksCompilerDiagnostic.eventTypeMisMachParamCount
                        ))
                }

                return !event.isEmpty && function != nil
                    ? EventNativeMeta(
                        kind: .action,
                        position: position,
                        event: event,
                        description: description,
                        dataBinding: dataBinding,
                        isOptinalFunction: isOptinalFunction,
                        then: then,
                        block: blockAttribute,
                        valriable: binding
                    ) : nil
            }, diagnostic
        )
    }
}
