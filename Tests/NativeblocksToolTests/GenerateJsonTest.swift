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
        
        let actionJsons = provider.actionsJson.first?.value
        
        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")
        
        print("\(JsonGenerateType.integration.fileName)=>")
        print(String(actionJsons![JsonGenerateType.integration]!))
        
        print("\(JsonGenerateType.data.fileName)=>")
        print(String(actionJsons![JsonGenerateType.data]!))
        
        print("\(JsonGenerateType.event.fileName)=>")
        print(String(actionJsons![JsonGenerateType.event]!))
        
        print("\(JsonGenerateType.propertie.fileName)=>")
        print(String(actionJsons![JsonGenerateType.propertie]!))
        print("=========================")
        
        XCTAssertEqual(
            String(actionJsons![JsonGenerateType.integration]!),
            """
            {"platFormSupport":"IOS","documentation":"","keyType":"ALERT","price":0,"organizationId":"","description":"Nativeblocks alert action","imageIcon":"","name":"Alert","kind":"ACTION"}
            """
        )
        XCTAssertEqual(
            String(actionJsons![JsonGenerateType.data]!),
            """
            [{"key":"message","type":"STRING","description":""}]
            """
        )
        XCTAssertEqual(
            String(actionJsons![JsonGenerateType.event]!),
            """
            [{"event":"END","description":""}]
            """
        )
        XCTAssertEqual(
            String(actionJsons![JsonGenerateType.propertie]!),
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
        
        let jsons = provider.blocksJson.first?.value
        
        
        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")
        
        print("\(JsonGenerateType.integration.fileName)=>")
        print(String(jsons![JsonGenerateType.integration]!))
        
        print("\(JsonGenerateType.data.fileName)=>")
        print(String(jsons![JsonGenerateType.data]!))
        
        print("\(JsonGenerateType.event.fileName)=>")
        print(String(jsons![JsonGenerateType.event]!))
        
        print("\(JsonGenerateType.propertie.fileName)=>")
        print(String(jsons![JsonGenerateType.propertie]!))
                
        print("\(JsonGenerateType.slot.fileName)=>")
        print(String(jsons![JsonGenerateType.slot]!))
        print("=========================")
        
        XCTAssertEqual(
            jsons![JsonGenerateType.integration]!,
            """
            {"platFormSupport":"IOS","documentation":"","keyType":"XBUTTON","price":0,"organizationId":"","description":"This is a button","imageIcon":"","name":"X button","kind":"BLOCK"}
            """
        )
        XCTAssertEqual(
            jsons![JsonGenerateType.data]!,
            """
            [{"key":"text","type":"STRING","description":"Button text"}]
            """
        )
        XCTAssertEqual(
            jsons![JsonGenerateType.event]!,
            """
            [{"event":"onClick","description":"Button on click"}]
            """
        )
        XCTAssertEqual(
            jsons![JsonGenerateType.propertie]!,
            """
            [{"valuePicker":"color-picker","valuePickerGroup":"General","valuePickerOptions":"[]","value":"#ffffffff","key":"background","type":"STRING","description":""},{"valuePicker":"dropdown","valuePickerGroup":"Size","valuePickerOptions":"[{\\"id\\":\\"S\\",\\"text\\":\\"Small\\"},{\\"id\\":\\"M\\",\\"text\\":\\"Medium\\"},{\\"id\\":\\"L\\",\\"text\\":\\"Large\\"}]","value":"S","key":"size","type":"STRING","description":"Button size"}]
            """
        )
        XCTAssertEqual(
            jsons![JsonGenerateType.slot]!,
            """
            [{"description":"Button leading icon","slot":"onLeadingIcon"},{"description":"Button trailing icon","slot":"onTrailingIcon"}]
            """
        )
    }
}
