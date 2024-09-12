import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder

public struct BlockExtractor {
    static let NativeBlockDataType = "NativeBlockData"
    static let NativeBlockPropType = "NativeBlockProp"
    static let NativeBlockEventType = "NativeBlockEvent"
    static let NativeBlockSlotType = "NativeBlockSlot"

    public static func extractVariable(from structDecl: StructDeclSyntax) -> ([NativeMeta], [Diagnostic]) {
        var meta: [NativeMeta] = []
        var errors: [Diagnostic] = []
        var position = 0
        for member in structDecl.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self)
            else {
                continue
            }
            position += 1

            guard let (type, _) = SyntaxUtils.getType(from: varDecl)
            else {
                continue
            }

            switch type {
            case NativeBlockDataType:
                do {
                    guard let (block, blockErrors) = extractDataBlock(from: varDecl, startPosition: position)
                    else {
                        continue
                    }
                    position = block.last?.position ?? position
                    errors.append(contentsOf: blockErrors)
                    meta.append(contentsOf: block)
                }
            case NativeBlockPropType:
                do {
                    guard let (block, blockErrors) = extractPropBlock(from: varDecl, startPosition: position)
                    else {
                        continue
                    }
                    position = block.last?.position ?? position
                    errors.append(contentsOf: blockErrors)
                    meta.append(contentsOf: block)
                }
            case NativeBlockEventType:
                do {
                    guard let (block, blockErrors) = extractEventBlock(from: varDecl, startPosition: position)
                    else {
                        continue
                    }
                    position = block.last?.position ?? position
                    errors.append(contentsOf: blockErrors)
                    meta.append(contentsOf: block)
                }
            case NativeBlockSlotType:
                do {
                    guard let (block, blockErrors) = extractSlotBlock(from: varDecl, startPosition: position)
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

        let dataBlocks = meta.compactMap { $0 as? DataNativeMeta }
        let eventBlocks = meta.compactMap { $0 as? EventNativeMeta }

        for event in eventBlocks {
            for binding in event.dataBinding {
                if dataBlocks.first(where: { data in data.key == binding }) == nil {
                    errors.append(
                        Diagnostic(
                            node: event.valriable!,
                            message: NativeblocksCompilerDiagnostic.eventDataMissing
                        ))
                }
            }
        }

        return (meta, errors)
    }

    private static func extractDataBlock(from varDecl: VariableDeclSyntax, startPosition: Int)
        -> ([DataNativeMeta], [Diagnostic])?
    {
        var position = startPosition
        let attributes = varDecl.attributes
        var description = "" as String?
        var blockAttribute: AttributeSyntax?
        var diagnostic: [Diagnostic] = []

        blockAttribute = SyntaxUtils.extractAttribute(for: NativeBlockDataType, from: attributes)

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

    private static func extractPropBlock(from varDecl: VariableDeclSyntax, startPosition: Int)
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

        blockAttribute = SyntaxUtils.extractAttribute(for: NativeBlockPropType, from: attributes)

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

    private static func extractEventBlock(from varDecl: VariableDeclSyntax, startPosition: Int)
        -> ([EventNativeMeta], [Diagnostic])?
    {
        var position = startPosition
        let attributes = varDecl.attributes
        var description = ""
        var dataBinding: [String] = []
        var isOptinalFunction = false
        var blockAttribute: AttributeSyntax?
        var diagnostic: [Diagnostic] = []

        blockAttribute = SyntaxUtils.extractAttribute(for: NativeBlockEventType, from: attributes)

        guard blockAttribute != nil else { return nil }

        description = SyntaxUtils.extractDescription(from: blockAttribute!) ?? ""
        dataBinding = SyntaxUtils.extractDataBinding(from: blockAttribute!) ?? []

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
                        kind : .block,
                        position: position,
                        event: event,
                        description: description,
                        dataBinding: dataBinding,
                        isOptinalFunction: isOptinalFunction,
                        block: blockAttribute,
                        valriable: binding
                    ) : nil
            }, diagnostic
        )
    }

    private static func extractSlotBlock(from varDecl: VariableDeclSyntax, startPosition: Int)
        -> ([SlotNativeMeta], [Diagnostic])?
    {
        var position = startPosition
        let attributes = varDecl.attributes
        var description = ""
        var blockAttribute: AttributeSyntax?
        var diagnostic: [Diagnostic] = []

        blockAttribute = SyntaxUtils.extractAttribute(for: NativeBlockSlotType, from: attributes)

        guard blockAttribute != nil else { return nil }

        description = SyntaxUtils.extractDescription(from: blockAttribute!) ?? ""

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
                let slot = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""

                var isOptinalFunction = false
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

                if parameters.count > 1 {
                    diagnostic.append(
                        Diagnostic(
                            node: binding,
                            message: NativeblocksCompilerDiagnostic.blockIndexParamLimit
                        ))
                } else if parameters.count == 1 {
                    if let type = parameters.first?.as(TupleTypeElementSyntax.self)?.type.as(IdentifierTypeSyntax.self)?.name.text {
                        if type != "BlockIndex" {
                            diagnostic.append(
                                Diagnostic(
                                    node: binding,
                                    message: NativeblocksCompilerDiagnostic.blockIndexParamLimit
                                ))
                        }
                    }
                }

                return !slot.isEmpty
                    ? SlotNativeMeta(
                        position: position,
                        slot: slot,
                        description: description,
                        hasBlockIndex: parameters.count == 1,
                        isOptinalFunction: isOptinalFunction,
                        block: blockAttribute,
                        valriable: binding
                    ) : nil
            }, diagnostic
        )
    }
}
