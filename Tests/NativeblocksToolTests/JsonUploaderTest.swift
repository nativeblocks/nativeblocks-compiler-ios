import NativeblocksTool
import XCTest

final class JsonUploaderTest: XCTestCase {
    func testBlockUpload() throws {
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

        let jsonUploader = JsonUploader(endpoint: "http://localhost:8585/graphql", authToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhbGlkb255YWllX2dtYWlsLmNvbV84MjA3ZjQ1YS1mYTIyLTQyYjgtYmQzOC02NGMxYWU5OGMzODUiLCJpZHQiOiIwZmU2ZTEzNS03NDJmLTQxMjUtYTlhMS1jODhmZmY0NTViZDMiLCJlbWwiOiJhbGlkb255YWllQGdtYWlsLmNvbSIsImlhdCI6MTcyNjIzNjgyMiwiZXhwIjoxNzI4MDUxMjIyfQ.VGEYTDXe91HisOfKrE9jSQUIMHKfKUcaMUUBHCXBj28", organizationId: "466c02fe-9b27-42ea-8c24-8ca8fab66b57")
        
        let provider = JsonGenerator()
        try provider.generate(from: sources)
        
        let blocks = provider.blocks
        
        try jsonUploader.upload(blocks: blocks, actions: [])
        
        
        XCTAssertEqual(
            "",
            ""
        )
    }
}
