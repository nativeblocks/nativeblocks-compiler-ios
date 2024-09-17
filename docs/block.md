# Block

Blocks are composable functions that can be visually edited and configured within a Nativeblocks Studio. These
annotations provide metadata and define configurable properties, slots, and events for your composable, making them
usable as building blocks in a visual editor.

##### `@NativeBlock`

**Purpose:** Marks a composable function as a block.

**Parameters:**

* **`name`:** The display name of the block in the visual editor.
* **`keyType`:** A unique key used to identify the block type.
* **`description`:** A brief description of the block's functionality.

**Example:**

```swift
@NativeBlock(name : "X button", keyType : "XBUTTON", description : "This is a button")
```

##### `@NativeBlockProp`

**Purpose:** Defines a configurable property for the block.

**Parameters:**

* **`description`:** (Optional) A description of the property.
* **`valuePicker`:** (Optional) Specifies the type of UI element used to edit the property (e.g., dropdown, text field).
* **`valuePickerGroup`:** (Optional) Specifies the group name of the property to group all related properties.
* **`valuePickerOptions`:** (Optional) Provides options for dropdown value pickers.

**Example:**

```swift
@NativeBlockProp(
    description : "Button size",
    valuePicker : NativeBlockValuePicker.DROPDOWN,
    valuePickerOptions : [
        NativeBlockValuePickerOption(" S", "Small"),
        NativeBlockValuePickerOption(" M", "Medium"),
        NativeBlockValuePickerOption(" L", "Large")
    ]
)
```

#### `@NativeBlockData`

**Purpose:** Marks a parameter as a data input for the block. This data can be provided directly from frame screen's
variables.

**Parameters:**

* **`description`:** (Optional) A description of the data input.

**Example:**

```swift
@NativeBlockData(description : "Button text")
```

#### `@NativeBlockSlot`

**Purpose:** Defines a slot where other blocks can be inserted.This enables nesting and composition of blocks.

**Parameters:**

* **`description`:** (Optional) A description of the slot.

**Example:**

```swift
@NativeBlockSlot(description : "Button leading icon")
```

#### `@NativeBlockEvent`

**Purpose:** Defines an event that the block can trigger, such as a click or value change.

**Parameters:**

* **`description`:** (Optional) A description of the event.

**Example:**

```swift
@NativeBlockEvent(description : "Button on click")
```

This example demonstrates a simple button block with configurable properties, slots for icons, and a click event.

```swift
@NativeBlock(
    name: "X button",
    keyType: "XBUTTON",
    description: "This is a button"
)
struct XButton: View {
    @NativeBlockData(description: "Button text")
    @State var text: String
    @NativeBlockProp(valuePicker: NativeBlockValuePicker.COLOR_PICKER)
    @State var background: String = "#ffffffff"
    @NativeBlockProp(
        description: "Button size",
        valuePicker: NativeBlockValuePicker.DROPDOWN,
        valuePickerOptions: [
            NativeBlockValuePickerOption("S", "Small"),
            NativeBlockValuePickerOption("M", "Medium"),
            NativeBlockValuePickerOption("L", "Large"),
        ]
    )
    @State var size: String = "S"
    @NativeBlockSlot(description: "Button leading icon")
    var onLeadingIcon: () -> AnyView
    @NativeBlockSlot(description: "Button trailing icon")
    var onTrailingIcon: (() -> AnyView)? = nil
    @NativeBlockEvent(description: "Button on click")
    var onClick: (() -> Void)?

    var body: some View {
        Button(action: {
            onClick?()
        }) {
            HStack(spacing: 8) {
                onLeadingIcon()
                Text(text)
                    .font(.system(size: textSize))
                    .padding(padding)
                if let trailingIcon = onTrailingIcon {
                    trailingIcon()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(hex: background))
        .cornerRadius(24)
    }

    private var padding: EdgeInsets {
        switch size {
        case "M":
            return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        case "L":
            return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        default:  // "S"
            return EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        }
    }

    private var textSize: CGFloat {
        switch size {
        case "M":
            return 22
        case "L":
            return 32
        default:  // "S"
            return 16
        }
    }
}
```
