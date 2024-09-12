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
            """
        ]

        let provider = JsonGenerator()
        try provider.generate(from: sources)
        
        let (integrationString, datasString, eventsString, propertiesString) = try provider.generateAction(from: provider.actions.first!)

        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")
        print("integration.json=>")
        print(String(integrationString!))
        print("data.json=>")
        print(String(datasString!))
        print("events.json=>")
        print(String(eventsString!))
        print("properties.json=>")
        print(String(propertiesString!))
        print("=========================")
        
        XCTAssertEqual(
            String(integrationString!),
            """
            {"platFormSupport":"IOS","documentation":"","keyType":"ALERT","price":0,"description":"Nativeblocks alert action","imageIcon":"","name":"Alert","kind":"ACTION"}
            """
        )
        XCTAssertEqual(
            String(datasString!),
            """
            [{"key":"message","type":"STRING","description":""}]
            """
        )
        XCTAssertEqual(
            String(eventsString!),
            """
            [{"event":"END","description":""}]
            """
        )
        XCTAssertEqual(
            String(propertiesString!),
            """
            [{"valuePicker":"text-input","valuePickerGroup":"General","valuePickerOptions":"[]","value":"false","key":"animated","type":"BOOLEAN","description":""}]
            """
        )
    }
    
    func testBlockJsonGenerator() throws {
        let sources = [
            """
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
                    ],
                    valuePickerGroup : NativeBlockValuePickerPosition("Size")
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

            """
        ]

        
        let provider = JsonGenerator()
        try provider.generate(from: sources)
        
        let (integrationString, datasString, eventsString, propertiesString, slotsString)  = try provider.generateBlock(from: provider.blocks.first!)
        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")
        print("integration.json=>")
        print(String(integrationString!))
        print("data.json=>")
        print(String(datasString!))
        print("events.json=>")
        print(String(eventsString!))
        print("properties.json=>")
        print(String(propertiesString!))
        print("slots.json=>")
        print(String(slotsString!))
        print("=========================")
        
        XCTAssertEqual(
            integrationString!,
            """
            {"platFormSupport":"IOS","documentation":"","keyType":"XBUTTON","price":0,"description":"This is a button","imageIcon":"","name":"X button","kind":"BLOCK"}
            """
        )
        XCTAssertEqual(
            datasString!,
            """
            [{"key":"text","type":"STRING","description":"Button text"}]
            """
        )
        XCTAssertEqual(
            eventsString!,
            """
            [{"event":"onClick","description":"Button on click"}]
            """
        )
        XCTAssertEqual(
            propertiesString!,
            """
            [{"valuePicker":"color-picker","valuePickerGroup":"General","valuePickerOptions":"[]","value":"#ffffffff","key":"background","type":"STRING","description":""},{"valuePicker":"dropdown","valuePickerGroup":"Size","valuePickerOptions":"[{\\"id\\":\\"S\\",\\"text\\":\\"Small\\"},{\\"id\\":\\"M\\",\\"text\\":\\"Medium\\"},{\\"id\\":\\"L\\",\\"text\\":\\"Large\\"}]","value":"S","key":"size","type":"STRING","description":"Button size"}]
            """
        )
        XCTAssertEqual(
            slotsString!,
            """
            [{"description":"Button leading icon","slot":"onLeadingIcon"},{"description":"Button trailing icon","slot":"onTrailingIcon"}]
            """
        )
    }
}
