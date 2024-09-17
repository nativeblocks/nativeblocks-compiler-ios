import NativeblocksTool
import XCTest

final class JsonUploaderTest: XCTestCase {
    func testBlockUpload() throws {
        let sources = [
            """
            @NativeBlock(
                name: "Text",
                keyType: "TEXT",
                description: "Nativeblocks text block"
            )
            struct NativeText: View {
                @NativeBlockData
                @State var text: String
                @NativeBlockProp(
                    valuePicker: NativeBlockValuePicker.COMBOBOX_INPUT,
                    valuePickerOptions: [
                        NativeBlockValuePickerOption("match", "Match parent"),
                        NativeBlockValuePickerOption("wrap", "Wrap content"),
                    ]
                )
                @State var width: String = "wrap"
                @NativeBlockProp(
                    valuePicker: NativeBlockValuePicker.COMBOBOX_INPUT,
                    valuePickerOptions: [
                        NativeBlockValuePickerOption("match", "Match parent"),
                        NativeBlockValuePickerOption("wrap", "Wrap content"),
                    ]
                )
                @State var height: String = "wrap"
                @NativeBlockProp
                @State var fontFamily: String = "default"
                @NativeBlockProp(valuePicker: NativeBlockValuePicker.NUMBER_INPUT)
                @State var fontSize: Double = 14.0
                @NativeBlockProp(valuePicker: NativeBlockValuePicker.COLOR_PICKER)
                @State var textColor: String = "#ffffffff"
                @NativeBlockProp(
                    valuePicker: NativeBlockValuePicker.DROPDOWN,
                    valuePickerOptions: [
                        NativeBlockValuePickerOption("start", "start"),
                        NativeBlockValuePickerOption("center", "center"),
                        NativeBlockValuePickerOption("end", "end"),
                        NativeBlockValuePickerOption("justify", "justify"),
                    ]
                )
                @State var textAlign: String = "start"
                @NativeBlockProp(
                    valuePicker: NativeBlockValuePicker.DROPDOWN,
                    valuePickerOptions: [
                        NativeBlockValuePickerOption("thin", "thin"),
                        NativeBlockValuePickerOption("extraLight", "extraLight"),
                        NativeBlockValuePickerOption("light", "light"),
                        NativeBlockValuePickerOption("normal", "normal"),
                        NativeBlockValuePickerOption("medium", "medium"),
                        NativeBlockValuePickerOption("semiBold", "semiBold"),
                        NativeBlockValuePickerOption("bold", "bold"),
                        NativeBlockValuePickerOption("extraBold", "extraBold"),
                        NativeBlockValuePickerOption("black", "black"),
                    ]
                )
                @State var fontWeight: String = "normal"
                @NativeBlockProp(
                    valuePicker: NativeBlockValuePicker.DROPDOWN,
                    valuePickerOptions: [
                        NativeBlockValuePickerOption("clip", "clip"),
                        NativeBlockValuePickerOption("ellipsis", "ellipsis"),
                        NativeBlockValuePickerOption("visible", "visible"),
                    ]
                )
                @State var overflow: String = "clip"
                @NativeBlockProp(valuePicker: NativeBlockValuePicker.NUMBER_INPUT)
                @State var minLines: Int = 1
                @NativeBlockProp(valuePicker: NativeBlockValuePicker.NUMBER_INPUT)
                @State var maxLines: Int = 9999
                var body: some View {
                    Text(text)
                        .font(
                            typographyBuilder(
                                fontFamily: fontFamily,
                                fontWeight: fontWeightMapper(fontWeight),
                                fontSize: fontSize
                            )
                        )
                        .foregroundColor(Color(hex: textColor))
                        .multilineTextAlignment(textAlignmentMapper(textAlign))
                        .lineLimit(maxLines)
                        .minLine(minLines)
                        .truncationMode(textOverflowMapper(overflow))
                        .widthAndHeightModifier(width, height)
                }
            }

            """
        ]

        let endpoint = ""
        let authToken = ""
        let organizationId = ""

        if !endpoint.isEmpty || authToken.isEmpty || organizationId.isEmpty {
            return
        }

        let jsonUploader = JsonUploader(
            endpoint: endpoint,
            authToken: authToken,
            organizationId: organizationId
        )

        let provider = JsonGenerator()
        try provider.generate(from: sources)

        let blocks = provider.blocks

        try jsonUploader.upload(blocks: blocks, actions: [])
    }
}
