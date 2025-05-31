import NativeblocksTool
import XCTest

final class GenerateJsonTest: XCTestCase {

    func testJsonMetaTypeFileName() throws {
        for metaType in JsonMetaType.allCases {
            switch metaType {
            case .integration:
                XCTAssertEqual(metaType.fileName, "integration.json")
            case .data:
                XCTAssertEqual(metaType.fileName, "data.json")
            case .event:
                XCTAssertEqual(metaType.fileName, "events.json")
            case .properties:
                XCTAssertEqual(metaType.fileName, "properties.json")
            case .slot:
                XCTAssertEqual(metaType.fileName, "slots.json")
            }
        }
    }

    func testActionJsonGenerator() throws {
        let sources = [
            """
            @NativeAction(
                name: "Alert",
                keyType: "ALERT",
                description: "Nativeblocks alert action",
                version: 2,
                versionName: "0.0.2"
            )
            public class NativeAlert {
                var alertController: UIAlertController
                init(alertController: UIAlertController) {
                    self.alertController = alertController
                }

                @NativeActionParameter
                struct Parameter {
                    @NativeActionData( deprecated: true,deprecatedReason: "reasion")
                    var message: String
                    @NativeActionProp( deprecated: true,deprecatedReason: "reasion",defaultValue: "false")
                    var animated: Bool = false
                    @NativeActionEvent( deprecated: true,deprecatedReason: "reasion")
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
            """
        ]

        let provider = JsonGenerator()
        try provider.generate(from: sources)

        let actionJsons = provider.actionsJson.first?.value

        do {
            if let integrationObject = try JSONSerialization.jsonObject(with: actionJsons![JsonMetaType.integration]!) as? [String: Any] {
                XCTAssertEqual(integrationObject.count, 14)
                XCTAssertEqual(integrationObject["documentation"] as! String, "")
                XCTAssertEqual(integrationObject["description"] as! String, "Nativeblocks alert action")
                XCTAssertEqual(integrationObject["imageIcon"] as! String, "")
                XCTAssertEqual(integrationObject["version"] as! Int, 2)
                XCTAssertEqual(integrationObject["versionName"] as! String, "0.0.2")
                XCTAssertEqual(integrationObject["deprecatedReason"] as! String, "")
                XCTAssertEqual(integrationObject["platformSupport"] as! String, "IOS")
                XCTAssertEqual(integrationObject["deprecated"] as! Bool, false)
                XCTAssertEqual(integrationObject["price"] as! Int, 0)
                XCTAssertEqual(integrationObject["keyType"] as! String, "ALERT")
                XCTAssertEqual(integrationObject["kind"] as! String, "ACTION")
                XCTAssertEqual(integrationObject["organizationId"] as! String, "")
                XCTAssertEqual(integrationObject["name"] as! String, "Alert")
                XCTAssertEqual(integrationObject["public"] as! Bool, false)
            } else {
                XCTFail("Failed to parse integration JSON object")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

        do {
            if let array = try JSONSerialization.jsonObject(with: actionJsons![JsonMetaType.data]!) as? [[String: Any]],
                let object = array.first
            {
                XCTAssertEqual(object.count, 5)
                XCTAssertEqual(object["deprecatedReason"] as! String, "reasion")
                XCTAssertEqual(object["key"] as! String, "message")
                XCTAssertEqual(object["type"] as! String, "STRING")
                XCTAssertEqual(object["description"] as! String, "")
                XCTAssertEqual(object["deprecated"] as! Bool, true)
            } else {
                XCTFail("Failed to parse JSON as array of dictionaries")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

        do {
            if let array = try JSONSerialization.jsonObject(with: actionJsons![JsonMetaType.event]!) as? [[String: Any]],
                let object = array.first
            {
                XCTAssertEqual(object.count, 4)
                XCTAssertEqual(object["deprecatedReason"] as! String, "reasion")
                XCTAssertEqual(object["event"] as! String, "END")
                XCTAssertEqual(object["description"] as! String, "")
                XCTAssertEqual(object["deprecated"] as! Bool, true)
            } else {
                XCTFail("Failed to parse JSON as array of dictionaries")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

        do {
            if let array = try JSONSerialization.jsonObject(with: actionJsons![JsonMetaType.properties]!) as? [[String: Any]],
                let object = array.first
            {
                XCTAssertEqual(object.count, 9)
                XCTAssertEqual(object["deprecatedReason"] as! String, "reasion")
                XCTAssertEqual(object["valuePicker"] as! String, "text-input")
                XCTAssertEqual(object["valuePickerGroup"] as! String, "General")
                XCTAssertEqual(object["valuePickerOptions"] as! String, "[]")
                XCTAssertEqual(object["value"] as! String, "false")
                XCTAssertEqual(object["key"] as! String, "animated")
                XCTAssertEqual(object["type"] as! String, "BOOLEAN")
                XCTAssertEqual(object["description"] as! String, "")
                XCTAssertEqual(object["deprecated"] as! Bool, true)

            } else {
                XCTFail("Failed to parse JSON as array of dictionaries")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

    }

    func testBlockJsonGenerator() throws {
        let sources = [
            """
            @NativeBlock(
                name: "X button",
                keyType: "XBUTTON",
                description: "This is a button",
                version: 2,
                versionName: "0.0.2",
                deprecated: true,
                deprecatedReason: "reasion"
            )
            struct XButton: View {
                @NativeBlockData(description: "Button text")
                var text: String
                @NativeBlockProp(valuePicker: NativeBlockValuePicker.COLOR_PICKER,defaultValue: "#ffffffff")
                var background: String = "#ffffffff"
                @NativeBlockProp(
                    description: "Button size",
                    valuePicker: NativeBlockValuePicker.DROPDOWN,
                    valuePickerOptions: [
                        NativeBlockValuePickerOption("S", "Small"),
                        NativeBlockValuePickerOption("M", "Medium"),
                        NativeBlockValuePickerOption("L", "Large"),
                    ],
                    valuePickerGroup : NativeBlockValuePickerPosition("Size"),
                    deprecated: true,deprecatedReason: "reasion",
                    defaultValue: "S"
                )
                @State var size: String = "S"
                @NativeBlockSlot(description: "Button leading icon",deprecated: true,deprecatedReason: "reasion")
                var onLeadingIcon: () -> AnyView
                @NativeBlockSlot(description: "Button trailing icon",deprecated: true,deprecatedReason: "reasion")
                var onTrailingIcon: (() -> AnyView)? = nil
                @NativeBlockEvent(description: "Button on click",deprecated: true,deprecatedReason: "reasion")
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
            """
        ]

        let provider = JsonGenerator()
        try provider.generate(from: sources)

        let jsons = provider.blocksJson.first?.value

        do {
            if let object = try JSONSerialization.jsonObject(with: jsons![JsonMetaType.integration]!) as? [String: Any] {
                XCTAssertEqual(object.count, 14)
                XCTAssertEqual(object["documentation"] as! String, "")
                XCTAssertEqual(object["description"] as! String, "This is a button")
                XCTAssertEqual(object["imageIcon"] as! String, "")
                XCTAssertEqual(object["version"] as! Int, 2)
                XCTAssertEqual(object["versionName"] as! String, "0.0.2")
                XCTAssertEqual(object["deprecatedReason"] as! String, "reasion")
                XCTAssertEqual(object["platformSupport"] as! String, "IOS")
                XCTAssertEqual(object["deprecated"] as! Bool, true)
                XCTAssertEqual(object["price"] as! Int, 0)
                XCTAssertEqual(object["keyType"] as! String, "XBUTTON")
                XCTAssertEqual(object["kind"] as! String, "BLOCK")
                XCTAssertEqual(object["organizationId"] as! String, "")
                XCTAssertEqual(object["name"] as! String, "X button")
                XCTAssertEqual(object["public"] as! Bool, false)
            } else {
                XCTFail("Failed to parse integration JSON object")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

        do {
            if let array = try JSONSerialization.jsonObject(with: jsons![JsonMetaType.data]!) as? [[String: Any]],
                let object = array.first
            {
                XCTAssertEqual(object.count, 5)
                XCTAssertEqual(object["deprecatedReason"] as! String, "")
                XCTAssertEqual(object["key"] as! String, "text")
                XCTAssertEqual(object["type"] as! String, "STRING")
                XCTAssertEqual(object["description"] as! String, "Button text")
                XCTAssertEqual(object["deprecated"] as! Bool, false)
            } else {
                XCTFail("Failed to parse JSON as array of dictionaries")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

        do {
            if let array = try JSONSerialization.jsonObject(with: jsons![JsonMetaType.event]!) as? [[String: Any]],
                let object = array.first
            {
                XCTAssertEqual(object.count, 4)
                XCTAssertEqual(object["deprecatedReason"] as! String, "reasion")
                XCTAssertEqual(object["event"] as! String, "onClick")
                XCTAssertEqual(object["description"] as! String, "Button on click")
                XCTAssertEqual(object["deprecated"] as! Bool, true)
            } else {
                XCTFail("Failed to parse JSON as array of dictionaries")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

        do {
            if let array = try JSONSerialization.jsonObject(with: jsons![JsonMetaType.properties]!) as? [[String: Any]],
                let object = array.first
            {
                XCTAssertEqual(object.count, 9)
                XCTAssertEqual(object["deprecatedReason"] as! String, "")
                XCTAssertEqual(object["valuePicker"] as! String, "color-picker")
                XCTAssertEqual(object["valuePickerGroup"] as! String, "General")
                XCTAssertEqual(object["valuePickerOptions"] as! String, "[]")
                XCTAssertEqual(object["value"] as! String, "#ffffffff")
                XCTAssertEqual(object["key"] as! String, "background")
                XCTAssertEqual(object["type"] as! String, "STRING")
                XCTAssertEqual(object["description"] as! String, "")
                XCTAssertEqual(object["deprecated"] as! Bool, false)

            } else {
                XCTFail("Failed to parse JSON as array of dictionaries")
            }
        } catch {
            XCTFail("JSON parsing error: \(error)")
        }

    }
}
