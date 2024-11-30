# Action

actions are functions that can be invoked within a Nativeblocks Studio to perform specific tasks or operations. These
annotations provide metadata and define configurable properties, data inputs, and events for your actions, making them
usable as building actions in a visual editor.

##### `@NativeAction`

**Purpose:** Marks a class or function as an action.

**Parameters:**

* **`name`:** The display name of the action in the visual editor.
* **`keyType`:** A unique key used to identify the action type.
* **`description`:** A brief description of the action's functionality.

**Example:**

```swift
@NativeAction(
    keyType : "MY_ALERT",
    name : "My alert",
    description : "This is an alert"
)
```

##### `@NativeActionProp`

**Purpose:** Defines a configurable property for the action. These properties can be set visually in the editor.

**Parameters:**

* **`description`:** (Optional) A description of the property.
* **`valuePicker`:** (Optional) Specifies the type of UI element used to edit the property (e.g., dropdown, text field).
* **`valuePickerGroup`:** (Optional) Specifies the group name of the property to group all related properties.
* **`valuePickerOptions`:** (Optional) Provides options for dropdown value pickers.

**Example:**

```swift
@NativeActionProp(description : "show animation") showAnimation: String
```

##### `@NativeActionData`

**Purpose:** Marks a parameter as a data input for the action. This data can be provided directly without visual
configuration, often from other actions or data sources.

**Parameters:**

* **`description`:** (Optional) A description of the data input.

**Example:**

```swift
@NativeActionData(description : "message value") message: String
```

##### `@NativeActionEvent`

**Purpose:** Defines an event that the action can trigger, such as success, failure, or next updates.

**Parameters:**

* **`description`:** (Optional) A description of the data input.
* **`then`:** Specifies when the event should be triggered (e.g., success, failure, next, end).
* **`dataBinding`:** (Optional) An array of data input names to bind to the event handler parameters.

**Example:**

```swift
@NativeActionEvent(
    then : Then.NEXT
)
```

This example demonstrates an alert action with configurable properties (animated), data inputs (message), and events for completion (completion).

```swift
import Nativeblocks
import NativeblocksCompiler
import SwiftUI
import UIKit

@NativeAction(
    name: "Alert",
    keyType: "NATIVE_ALERT",
    description: "Nativeblocks alert action"
)
public class NativeAlert {
    var alertController: UIAlertController
    init(alertController: UIAlertController) {
        self.alertController = alertController
    }

    @NativeActionParameter
    struct Parameter {
        @NativeActionData
        var message: String
        @NativeActionProp
        var animated: Bool = false
        @NativeActionEvent
        var completion: (() -> Void)? = nil
    }

    @NativeActionFunction
    func show(
        param: Parameter
    ) {
        alertController.message = param.message
        alertController.present(
            animated: param.animated,
            completion: { param.completion?() }
        )
    }
}
```
