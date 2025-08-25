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
                return InternalRootView(blockProps: blockProps)
                """
            }
            try StructDeclSyntax("private struct InternalRootView: View") {
                try VariableDeclSyntax("var blockProps: BlockProps")
                try VariableDeclSyntax("@State private var resolved: ResolvedProperties")
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

                try InitializerDeclSyntax("init(blockProps: BlockProps)") {
                    """
                    self.blockProps = blockProps
                    """
                    """
                    resolved = ResolvedProperties.make(
                        blockProps: blockProps,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                    """
                }

                for data in metaData {
                    try VariableDeclSyntax(
                        """
                        @State private var  \(raw: data.key)DataValue = \(raw: dataDefaultMapper(dataItem: data))
                        """
                    )
                    try VariableDeclSyntax(
                        """
                        private var  \(raw: data.key)Data :  NativeVariableModel? {
                            blockProps.onFindVariable(blockProps.block?.data?["\(raw: data.key)"]?.value ?? "")
                        }
                        """
                    )
                }

                try VariableDeclSyntax(
                    """
                    @State private var visibility: Bool = true
                    """
                )
                try VariableDeclSyntax(
                    """
                    private var visibilityVariable: NativeVariableModel? {
                        blockProps.onFindVariable(blockProps.block?.visibility ?? "")
                    }
                    """
                )

                try VariableDeclSyntax(
                    """
                    var body: some View
                    """
                ) {
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
                            \($0.key): resolved.\($0.key)Prop
                            """
                        )
                    }

                    let eventArguments = metaEvent.map { event in
                        (
                            event.position,
                            """
                            \(event.event):\(event.isOptinalFunction ? "resolved.\(event.event)Event == nil ? nil :" : "") { \(event.dataBinding.map { "\($0)Param" }.joined(separator: ",")) \(event.dataBinding.isEmpty ? "" : "in")
                            \(event.dataBinding.map { param in
                                """
                                if var \(param)Updated = \(param)Data {
                                    \(param)Updated.value = String(describing: \(param)Param)
                                    blockProps.onVariableChange(\(param)Updated)
                                }
                                """
                            }.joined())
                             resolved.\(event.event)Event?()
                            }
                            """
                        )
                    }
                    let slotArguments = metaSlot.map { slot in
                        (
                            slot.position,
                            """
                            \(slot.slot): resolved.\(slot.slot)Slot == nil ? \(slot.isOptinalFunction ? "nil" : "{ \(slot.hasBlockIndex ? "index" : "")\(slot.hasBlockIndex && slot.hasBlockScope ? ", ":"")\(slot.hasBlockScope ? "scope" : "")\((slot.hasBlockIndex || slot.hasBlockScope) ? " in" : "") AnyView(EmptyView())}") : { \(slot.hasBlockIndex ? "index" : "")\(slot.hasBlockIndex && slot.hasBlockScope ? ", ":"")\(slot.hasBlockScope ? "scope" : "")\((slot.hasBlockIndex || slot.hasBlockScope) ? " in" : "")
                                (blockProps.onSubBlock(blockProps.block?.subBlocks ?? [:], resolved.\(slot.slot)Slot!, \(slot.hasBlockIndex ?"index": "-1"), \(slot.hasBlockScope ?"scope": "nil")))
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
                    Group {
                        if visibility {
                    """
                    """
                            \(raw: structName)(\n\(raw: arguments)\n)
                    """
                    """
                        } else {
                            EmptyView()
                        }
                    }
                    """
                    for data in metaData {
                        """
                        .task(id: \(raw: data.key)Data?.value ?? "") {
                        \(raw: data.key)DataValue = \(raw: dataTypeMapper(dataItem: data))
                        }
                        """
                    }
                    """
                    .task(id: visibilityVariable?.value ?? "") {
                        let rawValue = blockHandleVariableValue(blockProps: blockProps, variable: visibilityVariable) ?? "true"
                        visibility = rawValue != "false"
                    }
                    """
                    """
                    .onChange(of: blockProps.block?.properties?.hash() ?? 0) { _ in
                        resolved = ResolvedProperties.make(
                            blockProps: blockProps,
                            verticalSizeClass: verticalSizeClass,
                            horizontalSizeClass: horizontalSizeClass
                        )
                    }
                    """

                }
            }
            try StructDeclSyntax("private struct ResolvedProperties") {
                for prop in metaProp {
                    """
                    let \(raw: prop.key)Prop : \(raw: prop.type)
                    """
                }

                for event in metaEvent {
                    """
                    let \(raw: event.event)Event : (() -> Void)?
                    """
                }

                for slot in metaSlot {
                    """
                    let \(raw: slot.slot)Slot : NativeBlockSlotModel?
                    """
                }

                try FunctionDeclSyntax(
                    "static func make(blockProps: BlockProps, verticalSizeClass: UserInterfaceSizeClass?, horizontalSizeClass: UserInterfaceSizeClass?) -> ResolvedProperties"
                ) {
                    if !metaProp.isEmpty {
                        """
                        let properties = blockProps.block?.properties ?? [:]
                        """
                    }
                    """
                    return ResolvedProperties(\n
                    """
                    for prop in metaProp {
                        """
                        \(raw: prop.key)Prop : \(raw: propTypeMapper(item: prop) ?? ""),
                        """
                    }
                    for event in metaEvent {
                        """
                        \(raw: event.event)Event : blockProvideEvent(blockProps: blockProps, eventType: "\(raw: event.event)"),
                        """
                    }
                    for slot in metaSlot {
                        """
                        \(raw: slot.slot)Slot : blockProvideSlot(blockProps: blockProps, slotType: "\(raw: slot.slot)"),
                        """
                    }
                    """
                    \n)
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
                blockHandleVariableValue(blockProps: blockProps, variable: \(dataItem.key)Data) ?? "\(dataItem.value)"
                """
        case "INT", "INT64", "INT32", "INT16", "INT8", "UINT", "UINT64", "UINT32", "UINT16", "UINT8",
            "FLOAT", "FLOAT80", "FLOAT64",
            "FLOAT32", "FLOAT16", "DOUBLE":
            return
                """
                \(dataItem.type)(blockHandleVariableValue(blockProps: blockProps, variable: \(dataItem.key)Data) ?? "") ?? \(dataItem.value.isEmpty ? "0" : dataItem.value)
                """
        case "CGFLOAT":
            return
                """
                (blockHandleVariableValue(blockProps: blockProps, variable: \(dataItem.key)Data) ?? "").toCGFloat() ?? \(dataItem.value.isEmpty ? "0.0" : dataItem.value)
                """
        case "BOOL":
            return
                """
                Bool(blockHandleVariableValue(blockProps: blockProps, variable: \(dataItem.key)Data) ?? "") ?? \(dataItem.value.isEmpty ? "false" : dataItem.value)
                """
        default:
            return
                """
                """
        }
    }

    private static func dataDefaultMapper(dataItem: DataMeta) -> String {
        switch dataItem.type.uppercased() {
        case "STRING":
            return
                """
                "\(dataItem.value)"
                """
        case "INT", "INT64", "INT32", "INT16", "INT8", "UINT", "UINT64", "UINT32", "UINT16", "UINT8",
            "FLOAT", "FLOAT80", "FLOAT64",
            "FLOAT32", "FLOAT16", "DOUBLE":
            return
                """
                \(dataItem.value.isEmpty ? "0" : dataItem.value)
                """
        case "CGFLOAT":
            return
                """
                \(dataItem.value.isEmpty ? "0.0" : dataItem.value)
                """
        case "BOOL":
            return
                """
                \(dataItem.value.isEmpty ? "false" : dataItem.value)
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
                blockHandleTypeConverter(blockProps: blockProps, type:\(item.type).self).fromString(findWindowSizeClass(verticalSizeClass, horizontalSizeClass,properties["\(item.key)"]) ?? "\(item.value)")
                """
        }
    }
}
