import SwiftSyntax
import SwiftSyntaxBuilder
import _NativeblocksCompilerCommon

struct BlockCreator {
    static func create(
        structName: String,
        metaData: [DataMeta],
        metaProp: [PropertyMeta],
        metaEvent: [EventMeta],
        metaSlot: [SlotMeta],
        metaExtraParams: [ExtraParamMeta]
    ) throws -> StructDeclSyntax {
        return try StructDeclSyntax("public struct \(raw: structName)Block: INativeBlock") {
            try FunctionDeclSyntax("public func blockView(blockProps: BlockProps) -> any View") {
                """
                if let visibilityKey = blockProps.block?.visibility,
                       let visibility = blockProps.variables?[visibilityKey]?.value,
                       visibility == "false" {
                        return EmptyView()
                    }
                """
                """
                return InternalRootView(blockProps: blockProps)
                """
            }

            try StructDeclSyntax("private struct InternalRootView: View") {
                try VariableDeclSyntax("var blockProps: BlockProps")

                try VariableDeclSyntax(
                    """
                    @Environment(\\.verticalSizeClass) var verticalSizeClass
                    """
                )
                try VariableDeclSyntax(
                    """
                    @Environment(\\.horizontalSizeClass) var horizontalSizeClass
                    """
                )

                try VariableDeclSyntax(
                    """
                    var body: some View
                    """
                ) {
                    if !metaData.isEmpty {
                        """
                        let data = blockProps.block?.data ?? [:]
                        """
                    }
                    if !metaProp.isEmpty {
                        """
                        let properties = blockProps.block?.properties ?? [:]
                        """
                    }
                    if !metaSlot.isEmpty {
                        """
                        let slots = blockProps.block?.slots ?? [:]
                        """
                    }
                    if !metaEvent.isEmpty {
                        """
                        let action = blockProps.actions? [blockProps.block?.key ?? ""] ?? []
                        """
                    }
                    """
                    //Block Data
                    """
                    for data in metaData {
                        """
                        let \(raw: data.key)Data = blockProps.variables?[data["\(raw: data.key)"]?.value ?? ""]
                        """
                    }
                    for data in metaData {
                        """
                        let \(raw: data.key)DataValue = \(raw: dataTypeMapper(dataItem: data))
                        """
                    }
                    """
                    //Block Properties
                    """
                    for prop in metaProp {
                        """
                        let \(raw: prop.key)Prop = \(raw: propTypeMapper(item: prop) ?? "")
                        """
                    }

                    """
                    //Block Events
                    """
                    for event in metaEvent {
                        """
                        let \(raw: event.event)Event = blockProvideEvent(blockProps: blockProps, action: action, eventType: "\(raw: event.event)")
                        """
                    }

                    """
                    //Block Slots
                    """
                    for slot in metaSlot {
                        """
                        let \(raw: slot.slot)Slot = blockProvideSlot(blockProps: blockProps, slots: slots, slotType: "\(raw: slot.slot)")
                        """
                    }

                    let dataArguments = metaData.map {
                        (
                            $0.position,
                            """
                            \($0.key): \($0.key)DataValue
                            """
                        )
                    }

                    let propArguments = metaProp.map {
                        (
                            $0.position,
                            """
                            \($0.key): \($0.key)Prop
                            """
                        )
                    }

                    let eventArguments = metaEvent.map { event in
                        (
                            event.position,
                            """
                            \(event.event):\(event.isOptinalFunction ? "\(event.event)Event == nil ? nil :" : "") { \(event.dataBinding.map { "\($0)Param" }.joined(separator: ",")) \(event.dataBinding.isEmpty ? "" : "in")
                            \(event.dataBinding.map { param in
                                """
                                if var \(param)Updated = \(param)Data {
                                    \(param)Updated.value = String(describing: \(param)Param)
                                    blockProps.onVariableChange?(\(param)Updated)
                                }
                                """
                            }.joined())
                            \(event.event)Event?()
                            }
                            """
                        )
                    }
                    let slotArguments = metaSlot.map { slot in
                        (
                            slot.position,
                            """
                            \(slot.slot): \(slot.slot)Slot == nil ? \(slot.isOptinalFunction ? "nil" : "{ \(slot.hasBlockIndex ? "index in" : "") AnyView(EmptyView())}") : { \(slot.hasBlockIndex ? "index in" : "")
                                (blockProps.onSubBlock?(blockProps.block?.subBlocks ?? [:], \(slot.slot)Slot!, \(slot.hasBlockIndex ?"index": "-1"))) ?? AnyView(EmptyView())
                            }
                            """
                        )
                    }

                    let extraParamArguments = metaExtraParams.map {
                        (
                            $0.position,
                            """
                            \($0.key): \($0.key)
                            """
                        )
                    }

                    let arguments = (dataArguments + propArguments + eventArguments + slotArguments + extraParamArguments)
                        .sorted { $0.0 < $1.0 }
                        .map { $0.1 }
                        .joined(separator: ",\n")

                    """
                    return \(raw: structName)(\n\(raw: arguments)\n)
                    """
                }
            }
        }
    }

    private static func dataTypeMapper(dataItem: DataMeta) -> String {
        switch dataItem.type.uppercased() {
        case "STRING":
            return
                """
                \(dataItem.key)Data?.value.toBlockDataStringValue(variables: blockProps.variables, hierarchy: blockProps.hierarchy) ?? "\(dataItem.value)"
                """
        case "INT", "INT64", "INT32", "INT16", "INT8", "UINT", "UINT64", "UINT32", "UINT16", "UINT8",
            "FLOAT", "FLOAT80", "FLOAT64",
            "FLOAT32", "FLOAT16", "DOUBLE":
            return
                """
                \(dataItem.type)(\(dataItem.key)Data?.value.toBlockDataStringValue(variables: blockProps.variables, hierarchy: blockProps.hierarchy) ?? "") ?? \(dataItem.value.isEmpty ? "0" : dataItem.value)
                """
        case "CGFLOAT":
            return
                """
                (\(dataItem.key)Data?.value.toBlockDataStringValue(variables: blockProps.variables, hierarchy: blockProps.hierarchy) ?? "").toCGFloat() ?? \(dataItem.value.isEmpty ? "0.0" : dataItem.value)
                """
        case "BOOL":
            return
                """
                Bool(\(dataItem.key)Data?.value.toBlockDataStringValue(variables: blockProps.variables, hierarchy: blockProps.hierarchy) ?? "") ?? \(dataItem.value.isEmpty ? "false" : dataItem.value)
                """
        default:
            return
                """
                """
        }
    }

    private static func propTypeMapper(item: PropertyMeta) -> String? {
        switch item.type.uppercased() {
        case "STRING":
            return
                """
                findWindowSizeClass(verticalSizeClass, horizontalSizeClass,properties["\(item.key)"]) ?? "\(item.value)"
                """
        case "INT", "INT64", "INT32", "INT16", "INT8", "UINT", "UINT64", "UINT32", "UINT16", "UINT8",
            "FLOAT", "FLOAT80", "FLOAT64",
            "FLOAT32", "FLOAT16", "DOUBLE":
            return
                """
                \(item.type)(findWindowSizeClass(verticalSizeClass, horizontalSizeClass,properties["\(item.key)"]) ?? "") ?? \(item.value.isEmpty ? "0" : item.value)
                """
        case "CGFLOAT":
            return
                """
                (findWindowSizeClass(verticalSizeClass, horizontalSizeClass,properties["\(item.key)"]) ?? "").toCGFloat() ?? \(item.value.isEmpty ? "0.0" : item.value)
                """
        case "BOOL":
            return
                """
                Bool(findWindowSizeClass(verticalSizeClass, horizontalSizeClass,properties["\(item.key)"]) ?? "") ??  \(item.value.isEmpty ? "false" : item.value)
                """
        default:
            return
                """
                NativeblocksManager.getInstance().getTypeConverter(\(item.type).self).fromString(findWindowSizeClass(verticalSizeClass, horizontalSizeClass,properties["\(item.key)"]) ?? "\(item.value)")
                """
        }
    }
}
