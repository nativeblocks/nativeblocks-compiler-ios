import NativeblocksTool
import XCTest

final class GenerateJsonTest: XCTestCase {
    func testActionJsonGenerator() throws {
        let sources = [
            """
            @NativeAction(
                name: "Alert",
                keyType: "ALERT",
                description: "Nativeblocks alert action"
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
                    @NativeActionProp( deprecated: true,deprecatedReason: "reasion")
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

        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")
        print("HELLO \(JsonMetaType.integration)")

        print("\(JsonMetaType.integration.fileName)=>")
        print(actionJsons![JsonMetaType.integration]!.toString()!)

        print("\(JsonMetaType.data.fileName)=>")
        print(actionJsons![JsonMetaType.data]!.toString()!)

        print("\(JsonMetaType.event.fileName)=>")
        print(actionJsons![JsonMetaType.event]!.toString()!)

        print("\(JsonMetaType.properties.fileName)=>")
        print(actionJsons![JsonMetaType.properties]!.toString()!)
        print("=========================")

        XCTAssertEqual(
            String(actionJsons![JsonMetaType.integration]!.toString()!),
            """
            {"documentation":"","description":"Nativeblocks alert action","imageIcon":"","version":1,"deprecatedReason":"","platformSupport":"IOS","deprecated":false,"price":0,"keyType":"ALERT","kind":"ACTION","organizationId":"","name":"Alert","public":false}
            """
        )
        XCTAssertEqual(
            String(actionJsons![JsonMetaType.data]!.toString()!),
            """
            [{"deprecatedReason":"reasion","key":"message","type":"STRING","description":"","deprecated":true}]
            """
        )
        XCTAssertEqual(
            String(actionJsons![JsonMetaType.event]!.toString()!),
            """
            [{"deprecatedReason":"reasion","event":"END","description":"","deprecated":true}]
            """
        )
        XCTAssertEqual(
            String(actionJsons![JsonMetaType.properties]!.toString()!),
            """
            [{"deprecatedReason":"reasion","valuePicker":"text-input","valuePickerGroup":"General","valuePickerOptions":"[]","value":"false","key":"animated","type":"BOOLEAN","description":"","deprecated":true}]
            """
        )
    }

    func testBlockJsonGenerator() throws {
        let sources = [
            """
            @NativeBlock(
                name: "X button",
                keyType: "XBUTTON",
                description: "This is a button",
                version: 2,
                deprecated: true,
                deprecatedReason: "reasion"
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
                    ],
                    valuePickerGroup : NativeBlockValuePickerPosition("Size"),
                    deprecated: true,deprecatedReason: "reasion"
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

        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")

        print("\(JsonMetaType.integration.fileName)=>")
        print(jsons![JsonMetaType.integration]!.toString()!)

        print("\(JsonMetaType.data.fileName)=>")
        print(jsons![JsonMetaType.data]!.toString()!)

        print("\(JsonMetaType.event.fileName)=>")
        print(jsons![JsonMetaType.event]!.toString()!)

        print("\(JsonMetaType.properties.fileName)=>")
        print(jsons![JsonMetaType.properties]!.toString()!)

        print("\(JsonMetaType.slot.fileName)=>")
        print(jsons![JsonMetaType.slot]!.toString()!)
        print("=========================")

        XCTAssertEqual(
            jsons![JsonMetaType.integration]!.toString()!,
            """
            {"documentation":"","description":"This is a button","imageIcon":"","version":2,"deprecatedReason":"reasion","platformSupport":"IOS","deprecated":true,"price":0,"keyType":"XBUTTON","kind":"BLOCK","organizationId":"","name":"X button","public":false}
            """
        )
        XCTAssertEqual(
            jsons![JsonMetaType.data]!.toString()!,
            """
            [{"deprecatedReason":"","key":"text","type":"STRING","description":"Button text","deprecated":false}]
            """
        )
        XCTAssertEqual(
            jsons![JsonMetaType.event]!.toString()!,
            """
            [{"deprecatedReason":"reasion","event":"onClick","description":"Button on click","deprecated":true}]
            """
        )
        XCTAssertEqual(
            jsons![JsonMetaType.properties]!.toString()!,
            """
            [{"deprecatedReason":"","valuePicker":"color-picker","valuePickerGroup":"General","valuePickerOptions":"[]","value":"#ffffffff","key":"background","type":"STRING","description":"","deprecated":false},{"deprecatedReason":"reasion","valuePicker":"dropdown","valuePickerGroup":"Size","valuePickerOptions":"[{\"id\":\"S\",\"text\":\"Small\"},{\"id\":\"M\",\"text\":\"Medium\"},{\"id\":\"L\",\"text\":\"Large\"}]","value":"S","key":"size","type":"STRING","description":"Button size","deprecated":true}]
            """
        )
        XCTAssertEqual(
            jsons![JsonMetaType.slot]!.toString()!,
            """
            [{"slot":"onLeadingIcon","deprecatedReason":"reasion","description":"Button leading icon","deprecated":true},{"slot":"onTrailingIcon","deprecatedReason":"reasion","description":"Button trailing icon","deprecated":true}]
            """
        )
    }
}
