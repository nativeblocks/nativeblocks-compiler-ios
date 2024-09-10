import NativeblocksTool
import XCTest

final class NativeblocksToolTest: XCTestCase {
    func testProcessSwiftFile() throws {
        let provider = NativeBlocksProvider()
        let providerCode = try provider.processFiles(files: [
            """
            @NativeBlock(name: "My text", keyType: "MYText", description: "text description")
            struct MyText {
                @NativeBlockData(description: "desc text")
                var text: String
                @NativeBlockProp(description: "desc number")
                var number: Int
            }

            @NativeBlock(name: "My text", keyType: "MYText2", description: "text description")
            struct MyText2 {
                @NativeBlockData(description: "desc text")
                var text: String
                @NativeBlockProp(description: "desc number")
                var number: Int
            }
            """,
            
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
            
        ],name : "Default")

        let providerCodeString = providerCode.formatted().description
        print("+++++++++++++++++++++++++")
        print(providerCodeString)
        print("--------------------------")
        XCTAssertEqual(
            providerCodeString,
            """
            public class DefaultBlockProvider {
                public static func provideBlocks() {
                    NativeblocksManager.getInstance().provideBlock(blockKeyType: "MyText", block: MyTextBlock())
                    NativeblocksManager.getInstance().provideBlock(blockKeyType: "MyText2", block: MyText2Block())
                }
                public static func provideActions() {
                    NativeblocksManager.getInstance().provideAction(actionKeyType: "NativeAlert", action: NativeAlertAction(action: action))
                }
            }
            """
        )
    }
}
