#if canImport(NativeblocksCompilerMacros)
import NativeblocksCompilerMacros

@NativeBlock(name: "My text", keyType: "MYText", description: "text description")
struct MyText {
    @NativeBlockData(description: "desc text")
    var text: String
    @NativeBlockProp(description: "desc number")
    var number: Int
}

#endif
