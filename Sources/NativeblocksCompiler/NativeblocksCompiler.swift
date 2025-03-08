// Macro to define a block with metadata and additional configuration.
// Automatically appends 'Block' to the struct name.
@attached(peer, names: suffixed(Block))
public macro NativeBlock(
    name: String,  // Display name of the block
    keyType: String,  // Unique identifier for the block
    description: String,  // A description of the block's purpose
    version: Int = 1,  // Version number (default: 1)
    deprecated: Bool = false,  // Indicates if the block is deprecated
    deprecatedReason: String = ""  // Reason for deprecation if applicable
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockMacro")

// Macro to define data properties within a block.
@attached(peer)
public macro NativeBlockData(
    description: String = "",  // A description of the data property
    deprecated: Bool = false,  // Indicates if the property is deprecated
    deprecatedReason: String = "",  // Reason for deprecation if applicable
    defaultValue: String = ""  // The default value for the Data.
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockDataMacro")

// Macro to define configurable properties within a block.
@attached(peer)
public macro NativeBlockProp(
    description: String = "",  // A description of the property
    valuePicker: NativeBlockValuePicker = NativeBlockValuePicker.TEXT_INPUT,  // Input type for the property
    valuePickerOptions: [NativeBlockValuePickerOption] = [],  // Dropdown or other selectable options
    valuePickerGroup: NativeBlockValuePickerPosition = NativeBlockValuePickerPosition("General"),  // Category for grouping
    deprecated: Bool = false,  // Indicates if the property is deprecated
    deprecatedReason: String = "",  // Reason for deprecation if applicable
    defaultValue: String = ""  // The default value for the property.
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockPropMacro")

// Macro to define events within a block.
@attached(peer)
public macro NativeBlockEvent(
    description: String = "",  // A description of the event
    dataBinding: [String] = [],  // Data bindings associated with the event
    deprecated: Bool = false,  // Indicates if the event is deprecated
    deprecatedReason: String = ""  // Reason for deprecation if applicable
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockEventMacro")

// Macro to define slots for child content in a block.
@attached(peer)
public macro NativeBlockSlot(
    description: String = "",  // A description of the slot
    deprecated: Bool = false,  // Indicates if the slot is deprecated
    deprecatedReason: String = ""  // Reason for deprecation if applicable
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeBlockSlotMacro")

// Enumeration of possible input types for block properties.
public enum NativeBlockValuePicker {
    case TEXT_INPUT  // Text input field
    case TEXT_AREA_INPUT  // Multi-line text area
    case NUMBER_INPUT  // Numeric input field
    case DROPDOWN  // Dropdown menu
    case COMBOBOX_INPUT  // Combobox input
    case COLOR_PICKER  // Color picker tool
}

// Defines an option for dropdown or other selection inputs.
public struct NativeBlockValuePickerOption {
    var id: String  // Unique identifier for the option
    var text: String  // Display text for the option
    public init(_ id: String, _ text: String) {
        self.id = id
        self.text = text
    }
}

// Defines categories or groups for block properties.
public struct NativeBlockValuePickerPosition {
    var text: String  // Name of the group
    public init(_ text: String) {
        self.text = text
    }
}

// Macro to define actions with metadata and configuration.
// Automatically appends 'Action' to the class name.
@attached(peer, names: suffixed(Action))
public macro NativeAction(
    name: String,  // Display name of the action
    keyType: String,  // Unique identifier for the action
    description: String,  // A description of the action's purpose
    version: Int = 1,  // Version number (default: 1)
    deprecated: Bool = false,  // Indicates if the action is deprecated
    deprecatedReason: String = ""  // Reason for deprecation if applicable
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionMacro")

// Macro to define input parameters for an action.
@attached(peer)
public macro NativeActionParameter(description: String = "") =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionParameterMacro")

// Macro to define the function logic for an action.
@attached(peer)
public macro NativeActionFunction(description: String = "") =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionFunctionMacro")

// Macro to define data properties within an action.
@attached(peer)
public macro NativeActionData(
    description: String = "",  // A description of the data property
    deprecated: Bool = false,  // Indicates if the property is deprecated
    deprecatedReason: String = "",  // Reason for deprecation if applicable
    defaultValue: String = ""  // The default value for the data.
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionDataMacro")

// Macro to define configurable properties for an action.
@attached(peer)
public macro NativeActionProp(
    description: String = "",  // A description of the property
    valuePicker: NativeActionValuePicker = NativeActionValuePicker.TEXT_INPUT,  // Input type for the property
    valuePickerOptions: [NativeActionValuePickerOption] = [],  // Dropdown or other selectable options
    valuePickerGroup: NativeActionValuePickerPosition = NativeActionValuePickerPosition("General"),  // Category for grouping
    deprecated: Bool = false,  // Indicates if the property is deprecated
    deprecatedReason: String = "",  // Reason for deprecation if applicable
    defaultValue: String = ""  // The default value for the property.
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionPropMacro")

// Macro to define events for an action.
@attached(peer)
public macro NativeActionEvent(
    description: String = "",  // A description of the event
    dataBinding: [String] = [],  // Data bindings associated with the event
    then: Then = Then.END,  // Specifies the next step after the event
    deprecated: Bool = false,  // Indicates if the event is deprecated
    deprecatedReason: String = ""  // Reason for deprecation if applicable
) =
    #externalMacro(module: "NativeblocksCompilerMacros", type: "NativeActionEventMacro")

// Enumeration of possible input types for action properties.
public enum NativeActionValuePicker {
    case TEXT_INPUT  // Text input field
    case TEXT_AREA_INPUT  // Multi-line text area
    case NUMBER_INPUT  // Numeric input field
    case DROPDOWN  // Dropdown menu
    case COMBOBOX_INPUT  // Combobox input
    case COLOR_PICKER  // Color picker tool
}

// Enumeration of possible outcomes for events.
public enum Then {
    case SUCCESS  // Indicates success
    case FAILURE  // Indicates failure
    case NEXT  // Proceed to the next step
    case END  // End the action chain
}

// Defines an option for dropdown or other selection inputs in actions.
public struct NativeActionValuePickerOption {
    var id: String  // Unique identifier for the option
    var text: String  // Display text for the option
    public init(_ id: String, _ text: String) {
        self.id = id
        self.text = text
    }
}

// Defines categories or groups for action properties.
public struct NativeActionValuePickerPosition {
    var text: String  // Name of the group
    public init(_ text: String) {
        self.text = text
    }
}
