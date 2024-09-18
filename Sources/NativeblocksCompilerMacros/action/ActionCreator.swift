import SwiftSyntax
import SwiftSyntaxBuilder
import _NativeblocksCompilerCommon

enum ActionCreator {
    static func create(
        structName: String,
        actionInfo: ActionMeta?,
        metaData: [DataMeta],
        metaProp: [PropertyMeta],
        metaEvent: [EventMeta]
    ) throws -> ClassDeclSyntax {
        return try ClassDeclSyntax("public class \(raw: structName)Action: INativeAction") {
            """
            var action: \(raw: structName)
            """
            """
            init(action: \(raw: structName)) {
                self.action = action
            }
            """
            try FunctionDeclSyntax("public func handle(actionProps: ActionProps)") {
                if actionInfo?.isAsync == true {
                    """
                    Task {

                    """
                }

                if !metaData.isEmpty {
                    """
                    let data = actionProps.trigger?.data ?? [:]
                    """
                }
                if !metaProp.isEmpty {
                    """
                    let properties = actionProps.trigger?.properties ?? [:]
                    """
                }

                """
                //Action trigger Data
                """
                for data in metaData {
                    """
                    let \(raw: data.key)Data = actionProps.variables?[data["\(raw: data.key)"]?.value ?? ""]
                    """
                }
                """
                //Action trigger properties
                """
                for prop in metaProp {
                    """
                    let \(raw: prop.key)Prop = \(raw: propTypeMapper(item: prop) ?? "")
                    """
                }

                let dataArguments = metaData.map {
                    (
                        $0.position,
                        """
                        \($0.key): \(dataTypeMapper(dataItem: $0) ?? "")
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
                        \(event.event): { \(event.dataBinding.map { "\($0)Param" }.joined(separator: ",")) \(event.dataBinding.isEmpty ? "" : "in")
                        \(event.dataBinding.map { param in
                            """
                            if var \(param)Updated = \(param)Data {
                                \(param)Updated.value = String(describing: \(param)Param)
                                actionProps.onVariableChange?(\(param)Updated)
                            }
                            """
                        }.joined())
                        \({ switch event.then {
                        case "SUCCESS":
                            return
                                """
                                if actionProps.trigger != nil {
                                    actionProps.onHandleSuccessNextTrigger?(actionProps.trigger!)
                                }
                                """
                        case "FAILURE":
                            return
                                """
                                if actionProps.trigger != nil {
                                    actionProps.onHandleFailureNextTrigger?(actionProps.trigger!)
                                }
                                """
                        case "NEXT":
                            return
                                """
                                if actionProps.trigger != nil {
                                    actionProps.onHandleNextTrigger?(actionProps.trigger!)
                                }
                                """
                        default: return ""
                        }}())
                        }
                        """
                    )
                }

                let arguments = (dataArguments + propArguments + eventArguments)
                    .sorted { $0.0 < $1.0 }
                    .map { $0.1 }
                    .joined(separator: ",\n")

                if actionInfo?.functionParamName.isEmpty == false && actionInfo?.parameterClass.isEmpty == false {
                    """
                    let param = \(raw: structName).\(raw: actionInfo?.parameterClass ?? "Struct")(\n\(raw: arguments))
                    """
                    """
                    \(raw: (actionInfo?.isAsync == true ? "await " : ""))action.\(raw: actionInfo?.functionName ?? "function")(param: \(raw: actionInfo?.functionParamName ?? "param"))
                    """
                } else {
                    """
                    \(raw: (actionInfo?.isAsync == true ? "await " : ""))action.\(raw: actionInfo?.functionName ?? "function")()
                    """
                }
                if actionInfo?.isAsync == true {
                    """
                    }
                    """
                }
            }
        }
    }

    private static func dataTypeMapper(dataItem: DataMeta) -> String? {
        switch dataItem.type.uppercased() {
        case "STRING":
            return
                """
                \(dataItem.key)Data?.value ?? ""
                """
        case "INT", "INT64", "INT32", "INT16", "INT8", "UINT", "UINT64", "UINT32", "UINT16", "UINT8",
            "FLOAT", "FLOAT80", "FLOAT64",
            "FLOAT32", "FLOAT16", "DOUBLE":
            return
                """
                \(dataItem.type)(\(dataItem.key)Data?.value ?? "") ?? 0
                """
        case "CGFLOAT":
            return
                """
                (\(dataItem.key)Data?.value ?? "").toCGFloat() ?? 0.0
                """
        case "BOOL":
            return
                """
                \(dataItem.key)Data?.value?.lowercased() == "true"
                """
        default:
            return nil
        }
    }

    private static func propTypeMapper(item: PropertyMeta) -> String? {
        switch item.type.uppercased() {
        case "STRING":
            return
                """
                properties["\(item.key)"]?.value ?? \(item.value.isEmpty ? "\"\"" : "\"\(item.value)\"")
                """
        case "INT", "INT64", "INT32", "INT16", "INT8", "UINT", "UINT64", "UINT32", "UINT16", "UINT8",
            "FLOAT", "FLOAT80", "FLOAT64",
            "FLOAT32", "FLOAT16", "DOUBLE":
            return
                """
                \(item.type)(properties["\(item.key)"]?.value ?? "") ?? \(item.value.isEmpty ? "0" : item.value)
                """
        case "CGFLOAT":
            return
                """
                (properties["\(item.key)"]?.value ?? "").toCGFloat() ?? \(item.value.isEmpty ? "0.0" : item.value)
                """
        case "BOOL":
            return
                """
                Bool(properties["\(item.key)"]?.value ?? "") ??  \(item.value.isEmpty ? "false" : item.value)
                """
        default:
            return nil
        }
    }
}
