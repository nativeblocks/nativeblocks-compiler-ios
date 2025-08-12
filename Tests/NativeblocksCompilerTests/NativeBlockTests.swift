import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(NativeblocksCompilerMacros)
    import NativeblocksCompilerMacros

    let testBlockMacros: [String: Macro.Type] = [
        "NativeBlock": NativeBlockMacro.self,
        "NativeBlockData": NativeBlockDataMacro.self,
        "NativeBlockProp": NativeBlockPropMacro.self,
        "NativeBlockEvent": NativeBlockEventMacro.self,
        "NativeBlockSlot": NativeBlockSlotMacro.self,
    ]

#endif

final class NativeBlockTests: XCTestCase {
    func testNativeBlock() throws {
        #if canImport(NativeblocksCompilerMacros)
            assertMacroExpansion(
                """
                @NativeBlock(name: "My text", keyType: "MYText", description: "text description")
                struct MyText: View {
                    @NativeBlockData(description: "desc text")
                    var text: String
                    @NativeBlockProp(description: "desc number",defaultValue: "1")
                    var number: Int = 1
                    @NativeBlockProp(description: "desc number",defaultValue: "{\\\"name\\\":\\\"Name2\\\"}")
                    var user: User = User(name:"Name")
                    @NativeBlockProp(description: "Weight",defaultValue: "regular")
                    var fontWeight: Font.Weight.Big = .regular
                    var body: some View {
                        return Text(text+number)
                    }
                }
                """,
                expandedSource:
                    """
                    struct MyText: View {
                        var text: String
                        var number: Int = 1
                        var user: User = User(name:"Name")
                        var fontWeight: Font.Weight.Big = .regular
                        var body: some View {
                            return Text(text+number)
                        }
                    }

                    public struct MyTextBlock: INativeBlock {
                        public func blockView(blockProps: BlockProps) -> any View {
                            if let visibilityKey = blockProps.block?.visibility,
                                   let visibility = blockProps.variables[visibilityKey]?.value,
                                   visibility == "false" {
                                    return EmptyView()
                                }
                            return InternalRootView(blockProps: blockProps)
                        }
                        private struct InternalRootView: View {
                            var blockProps: BlockProps
                            @Environment(\\.verticalSizeClass) var verticalSizeClass
                            @Environment(\\.horizontalSizeClass) var horizontalSizeClass
                            @State private var  textDataValue = ""
                            var body: some View {
                                let data = blockProps.block?.data ?? [:]
                                let properties = blockProps.block?.properties ?? [:]
                                let textData = blockProps.variables[data["text"]?.value ?? ""]
                                let numberProp = Int(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["number"]) ?? "") ?? 1
                                let userProp = blockHandleTypeConverter(blockProps: blockProps, type: User.self).fromString(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["user"]) ?? "{\\\"name\\\":\\\"Name2\\\"}")
                                let fontWeightProp = blockHandleTypeConverter(blockProps: blockProps, type: Font.Weight.Big.self).fromString(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["fontWeight"]) ?? "regular")
                                return MyText(
                                    text: textDataValue,
                                    number: numberProp,
                                    user: userProp,
                                    fontWeight: fontWeightProp
                                )
                                .task(id: textData) {
                                    textDataValue = blockHandleVariableValue(blockProps: blockProps, variable: textData) ?? ""
                                }
                            }
                        }
                    }
                    """,

                macros: testBlockMacros
            )

        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testNativeBlockDefaultValue() throws {
        #if canImport(NativeblocksCompilerMacros)
            assertMacroExpansion(
                """
                @NativeBlock(
                    name: "My text",
                    keyType: "MyText",
                    description: "My text description"
                )
                struct MyText: View {
                    @NativeBlockProp(defaultValue: "true")
                    var visiable: Bool = true
                    @NativeBlockProp(defaultValue: "12")
                    var number: Int = 12
                    @NativeBlockProp(defaultValue: "")
                    var price: Float
                    @NativeBlockProp(defaultValue: "desc")
                    var description: String = "desc"

                    var body: some View {
                        return Text("\\(number)")
                    }
                }
                """,
                expandedSource:
                    """
                    struct MyText: View {
                        var visiable: Bool = true
                        var number: Int = 12
                        var price: Float
                        var description: String = "desc"

                        var body: some View {
                            return Text("\\(number)")
                        }
                    }

                    public struct MyTextBlock: INativeBlock {
                        public func blockView(blockProps: BlockProps) -> any View {
                            if let visibilityKey = blockProps.block?.visibility,
                                   let visibility = blockProps.variables[visibilityKey]?.value,
                                   visibility == "false" {
                                    return EmptyView()
                                }
                            return InternalRootView(blockProps: blockProps)
                        }
                        private struct InternalRootView: View {
                            var blockProps: BlockProps
                            @Environment(\\.verticalSizeClass) var verticalSizeClass
                            @Environment(\\.horizontalSizeClass) var horizontalSizeClass
                            var body: some View {
                                let properties = blockProps.block?.properties ?? [:]
                                let visiableProp = Bool(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["visiable"]) ?? "") ??  true
                                let numberProp = Int(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["number"]) ?? "") ?? 12
                                let priceProp = Float(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["price"]) ?? "") ?? 0
                                let descriptionProp = findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["description"]) ?? "desc"
                                return MyText(
                                    visiable: visiableProp,
                                    number: numberProp,
                                    price: priceProp,
                                    description: descriptionProp
                                )
                            }
                        }
                    }
                    """,

                macros: testBlockMacros
            )

        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testNativeBlockEvents() throws {
        #if canImport(NativeblocksCompilerMacros)
            assertMacroExpansion(
                """
                @NativeBlock(
                    name: "My text",
                    keyType: "MyText",
                    description: "My text description"
                )
                struct MyText: View {
                    @NativeBlockData(description: "desc")
                    var text: String
                    @NativeBlockData(description: "desc")
                    var number: Int
                    @NativeBlockData(description: "desc")
                    var percent: CGFloat
                    @NativeBlockProp(description: "desc")
                    var visiable: Bool
                    @NativeBlockEvent(
                        description: "desc",
                        dataBinding: ["text", "number"]
                    )
                    var onChange: (String, Int) -> Void
                    @NativeBlockEvent(
                        description: "desc",
                        dataBinding: ["text", "number"]
                    )
                    var onChange2: ((String, Int) -> Void)?
                    @NativeBlockEvent(description: "desc")
                    var onClick: () -> Void
                    var blockProps: BlockProps? = nil
                    var body: some View {
                        return Text("\\(text)")
                    }
                }
                """,
                expandedSource:
                    """
                    struct MyText: View {
                        var text: String
                        var number: Int
                        var percent: CGFloat
                        var visiable: Bool
                        var onChange: (String, Int) -> Void
                        var onChange2: ((String, Int) -> Void)?
                        var onClick: () -> Void
                        var blockProps: BlockProps? = nil
                        var body: some View {
                            return Text("\\(text)")
                        }
                    }

                    public struct MyTextBlock: INativeBlock {
                        public func blockView(blockProps: BlockProps) -> any View {
                            if let visibilityKey = blockProps.block?.visibility,
                                   let visibility = blockProps.variables[visibilityKey]?.value,
                                   visibility == "false" {
                                    return EmptyView()
                                }
                            return InternalRootView(blockProps: blockProps)
                        }
                        private struct InternalRootView: View {
                            var blockProps: BlockProps
                            @Environment(\\.verticalSizeClass) var verticalSizeClass
                            @Environment(\\.horizontalSizeClass) var horizontalSizeClass
                            @State private var  textDataValue = ""
                            @State private var  numberDataValue = 0
                            @State private var  percentDataValue = 0.0
                            var body: some View {
                                let data = blockProps.block?.data ?? [:]
                                let properties = blockProps.block?.properties ?? [:]
                                let action = blockProps.actions[blockProps.block?.key ?? ""] ?? []
                                let textData = blockProps.variables[data["text"]?.value ?? ""]
                                let numberData = blockProps.variables[data["number"]?.value ?? ""]
                                let percentData = blockProps.variables[data["percent"]?.value ?? ""]
                                let visiableProp = Bool(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["visiable"]) ?? "") ??  false
                                let onChangeEvent = blockProvideEvent(blockProps: blockProps, action: action, eventType: "onChange")
                                let onChange2Event = blockProvideEvent(blockProps: blockProps, action: action, eventType: "onChange2")
                                let onClickEvent = blockProvideEvent(blockProps: blockProps, action: action, eventType: "onClick")
                                return MyText(
                                    text: textDataValue,
                                    number: numberDataValue,
                                    percent: percentDataValue,
                                    visiable: visiableProp,
                                    onChange: { textParam, numberParam in
                                        if var textUpdated = textData {
                                            textUpdated.value = String(describing: textParam)
                                            blockProps.onVariableChange(textUpdated)
                                        }
                                        if var numberUpdated = numberData {
                                            numberUpdated.value = String(describing: numberParam)
                                            blockProps.onVariableChange(numberUpdated)
                                        }
                                        onChangeEvent?()
                                    },
                                    onChange2: onChange2Event == nil ? nil : { textParam, numberParam in
                                        if var textUpdated = textData {
                                            textUpdated.value = String(describing: textParam)
                                            blockProps.onVariableChange(textUpdated)
                                        }
                                        if var numberUpdated = numberData {
                                            numberUpdated.value = String(describing: numberParam)
                                            blockProps.onVariableChange(numberUpdated)
                                        }
                                        onChange2Event?()
                                    },
                                    onClick: {

                                        onClickEvent?()
                                    },
                                    blockProps: blockProps
                                )
                                .task(id: textData) {
                                    textDataValue = blockHandleVariableValue(blockProps: blockProps, variable: textData) ?? ""
                                }
                                .task(id: numberData) {
                                    numberDataValue = Int(blockHandleVariableValue(blockProps: blockProps, variable: numberData) ?? "") ?? 0
                                }
                                .task(id: percentData) {
                                    percentDataValue = (blockHandleVariableValue(blockProps: blockProps, variable: percentData) ?? "").toCGFloat() ?? 0.0
                                }
                            }
                        }
                    }
                    """,

                macros: testBlockMacros
            )

        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testNativeBlockSlots() throws {
        #if canImport(NativeblocksCompilerMacros)
            assertMacroExpansion(
                """
                @NativeBlock(
                    name: "Column",
                    keyType: "COLUMN",
                    description: "My Column description"
                )
                struct MyColumn<Content>: View where Content: View {
                    @NativeBlockSlot(description: "content description")
                    var content: (BlockIndex) -> Content?
                    @NativeBlockSlot(description: "content description")
                    var content1: (BlockIndex,Any) -> Content?
                    @NativeBlockSlot(description: "content description")
                    var content2: (Any) -> Content
                    @NativeBlockSlot(description: "content description")
                    var content3: (() -> Content)?
                    var body: some View {
                        return VStack {
                            content(-1)
                        }
                    }
                }
                """,
                expandedSource:
                    """
                    struct MyColumn<Content>: View where Content: View {
                        var content: (BlockIndex) -> Content?
                        var content1: (BlockIndex,Any) -> Content?
                        var content2: (Any) -> Content
                        var content3: (() -> Content)?
                        var body: some View {
                            return VStack {
                                content(-1)
                            }
                        }
                    }

                    public struct MyColumnBlock: INativeBlock {
                        public func blockView(blockProps: BlockProps) -> any View {
                            if let visibilityKey = blockProps.block?.visibility,
                                   let visibility = blockProps.variables[visibilityKey]?.value,
                                   visibility == "false" {
                                    return EmptyView()
                                }
                            return InternalRootView(blockProps: blockProps)
                        }
                        private struct InternalRootView: View {
                            var blockProps: BlockProps
                            @Environment(\\.verticalSizeClass) var verticalSizeClass
                            @Environment(\\.horizontalSizeClass) var horizontalSizeClass
                            var body: some View {
                                let slots = blockProps.block?.slots ?? [:]
                                let contentSlot = blockProvideSlot(blockProps: blockProps, slots: slots, slotType: "content")
                                let content1Slot = blockProvideSlot(blockProps: blockProps, slots: slots, slotType: "content1")
                                let content2Slot = blockProvideSlot(blockProps: blockProps, slots: slots, slotType: "content2")
                                let content3Slot = blockProvideSlot(blockProps: blockProps, slots: slots, slotType: "content3")
                                return MyColumn(
                                    content: contentSlot == nil ? { index in
                                        AnyView(EmptyView())
                                    } : { index in
                                        (blockProps.onSubBlock(blockProps.block?.subBlocks ?? [:], contentSlot!, index, nil))
                                    },
                                    content1: content1Slot == nil ? { index, scope in
                                        AnyView(EmptyView())
                                    } : { index, scope in
                                        (blockProps.onSubBlock(blockProps.block?.subBlocks ?? [:], content1Slot!, index, scope))
                                    },
                                    content2: content2Slot == nil ? { scope in
                                        AnyView(EmptyView())
                                    } : { scope in
                                        (blockProps.onSubBlock(blockProps.block?.subBlocks ?? [:], content2Slot!, -1, scope))
                                    },
                                    content3: content3Slot == nil ? nil : {
                                        (blockProps.onSubBlock(blockProps.block?.subBlocks ?? [:], content3Slot!, -1, nil))
                                    }
                                )
                            }
                        }
                    }
                    """,

                macros: testBlockMacros
            )

        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

}
