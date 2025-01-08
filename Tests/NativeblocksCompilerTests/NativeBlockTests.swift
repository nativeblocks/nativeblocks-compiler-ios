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
                    @NativeBlockProp(description: "desc number")
                    var number: Int
                    @NativeBlockProp(description: "desc number")
                    var user: User = User(name:"Name")
                    var body: some View {
                        return Text(text+number)
                    }
                }
                """,
                expandedSource:
                    """
                    struct MyText: View {
                        var text: String
                        var number: Int
                        var user: User = User(name:"Name")
                        var body: some View {
                            return Text(text+number)
                        }
                    }

                    public struct MyTextBlock: INativeBlock {
                        public func blockView(blockProps: BlockProps) -> any View {
                            if let visibilityKey = blockProps.block?.visibility,
                                   let visibility = blockProps.variables? [visibilityKey]?.value,
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
                                let data = blockProps.block?.data ?? [:]
                                let properties = blockProps.block?.properties ?? [:]
                                let textData = blockProps.variables? [data["text"]?.value ?? ""]
                                let numberProp = Int(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["number"]) ?? "") ?? 0
                                let userProp = try NativeblocksManager.getInstance().getSerializer(User.self).fromString(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["user"]) ?? "")
                                return MyText(
                                    text: textData?.value ?? "",
                                    number: numberProp,
                                    user: userProp
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
                    @NativeBlockProp()
                    var visiable: Bool = true
                    @NativeBlockProp()
                    var number: Int = 12
                    @NativeBlockProp()
                    var price: Float
                    @NativeBlockProp()
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
                                   let visibility = blockProps.variables? [visibilityKey]?.value,
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
                    @NativeBlockProp(description: "desc")
                    var visiable: Bool
                    @NativeBlockEvent(
                        description: "desc",
                        dataBinding: ["text", "number"]
                    )
                    var onChange: (String, Int) -> Void
                    @NativeBlockEvent(description: "desc")
                    var onClick: () -> Void
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
                        var visiable: Bool
                        var onChange: (String, Int) -> Void
                        var onClick: () -> Void
                        var body: some View {
                            return Text("\\(text)")
                        }
                    }

                    public struct MyTextBlock: INativeBlock {
                        public func blockView(blockProps: BlockProps) -> any View {
                            if let visibilityKey = blockProps.block?.visibility,
                                   let visibility = blockProps.variables? [visibilityKey]?.value,
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
                                let data = blockProps.block?.data ?? [:]
                                let properties = blockProps.block?.properties ?? [:]
                                let action = blockProps.actions? [blockProps.block?.key ?? ""] ?? []
                                let textData = blockProps.variables? [data["text"]?.value ?? ""]
                                let numberData = blockProps.variables? [data["number"]?.value ?? ""]
                                let visiableProp = Bool(findWindowSizeClass(verticalSizeClass, horizontalSizeClass, properties["visiable"]) ?? "") ??  false
                                let onChangeEvent = blockProvideEvent(blockProps: blockProps, action: action, eventType: "onChange")
                                let onClickEvent = blockProvideEvent(blockProps: blockProps, action: action, eventType: "onClick")
                                return MyText(
                                    text: textData?.value ?? "",
                                    number: Int(numberData?.value ?? "") ?? 0,
                                    visiable: visiableProp,
                                    onChange: { textParam, numberParam in
                                        if var textUpdated = textData {
                                            textUpdated.value = String(describing: textParam)
                                            blockProps.onVariableChange?(textUpdated)
                                        }
                                        if var numberUpdated = numberData {
                                            numberUpdated.value = String(describing: numberParam)
                                            blockProps.onVariableChange?(numberUpdated)
                                        }
                                        onChangeEvent?()
                                    },
                                    onClick: {

                                        onClickEvent?()
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
                    var content: (BlockIndex) -> Content
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
                        var content: (BlockIndex) -> Content
                        var body: some View {
                            return VStack {
                                content(-1)
                            }
                        }
                    }

                    public struct MyColumnBlock: INativeBlock {
                        public func blockView(blockProps: BlockProps) -> any View {
                            if let visibilityKey = blockProps.block?.visibility,
                                   let visibility = blockProps.variables? [visibilityKey]?.value,
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
                                let contentSlot = slots["content"]
                                return MyColumn(
                                    content: contentSlot == nil ? { index in
                                        AnyView(EmptyView())
                                    } : { index in
                                        (blockProps.onSubBlock?(blockProps.block?.subBlocks ?? [:], contentSlot!, index)) ?? AnyView(EmptyView())
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
