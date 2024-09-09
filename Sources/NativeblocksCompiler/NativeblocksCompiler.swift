@attached(peer, names: suffixed(Block))
public macro NativeBlock(name: String, keyType: String, description: String) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockMacro")

@attached(peer)
public macro NativeBlockData(description: String = "") =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockDataMacro")

@attached(peer)
public macro NativeBlockProp(
    description: String = "",
    valuePicker: NativeBlockValuePicker = NativeBlockValuePicker.TEXT_INPUT,
    valuePickerOptions: [NativeBlockValuePickerOption] = [],
    valuePickerGroup: NativeBlockValuePickerPosition = NativeBlockValuePickerPosition("General")
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockPropMacro")

@attached(peer)
public macro NativeBlockEvent(description: String = "", dataBinding: [String] = []) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockEventMacro")

@attached(peer)
public macro NativeBlockSlot(description: String = "") =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockSlotMacro")

public enum NativeBlockValuePicker {
    case TEXT_INPUT
    case TEXT_AREA_INPUT
    case NUMBER_INPUT
    case DROPDOWN
    case COMBOBOX_INPUT
    case COLOR_PICKER
}

public struct NativeBlockValuePickerOption {
    var id: String
    var text: String
    public init(_ id: String, _ text: String) {
        self.id = id
        self.text = text
    }
}

public struct NativeBlockValuePickerPosition {
    var text: String
    public init(_ text: String) {
        self.text = text
    }
}

@attached(peer, names: suffixed(Action))
public macro NativeAction(name: String, keyType: String, description: String) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionMacro")

@attached(peer)
public macro NativeActionParameter(description: String = "") =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionParameterMacro")

@attached(peer)
public macro NativeActionFunction(description: String = "") =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionFunctionMacro")

@attached(peer)
public macro NativeActionData(description: String = "") =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionDataMacro")

@attached(peer)
public macro NativeActionProp(
    description: String = "",
    valuePicker: NativeActionValuePicker = NativeActionValuePicker.TEXT_INPUT,
    valuePickerOptions: [NativeActionValuePickerOption] = [],
    valuePickerGroup: NativeActionValuePickerPosition = NativeActionValuePickerPosition("General")
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionPropMacro")

@attached(peer)
public macro NativeActionEvent(
    description: String = "",
    dataBinding: [String] = [],
    then: Then = Then.END
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionEventMacro")

public enum NativeActionValuePicker {
    case TEXT_INPUT
    case TEXT_AREA_INPUT
    case NUMBER_INPUT
    case DROPDOWN
    case COMBOBOX_INPUT
    case COLOR_PICKER
}

public enum Then {
    case SUCCESS
    case FAILURE
    case NEXT
    case END
}

public struct NativeActionValuePickerOption {
    var id: String
    var text: String
    public init(_ id: String, _ text: String) {
        self.id = id
        self.text = text
    }
}

public struct NativeActionValuePickerPosition {
    var text: String
    public init(_ text: String) {
        self.text = text
    }
}
