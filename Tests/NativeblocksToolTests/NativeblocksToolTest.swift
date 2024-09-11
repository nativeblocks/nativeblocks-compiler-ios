import _NativeblocksCompilerCommon
import NativeblocksTool
import XCTest

final class NativeblocksToolTest: XCTestCase {
    func testActionProviderGenerator() throws {
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

        let (_, actions) = NativeBlockVisitor.extractNatives(from: sources)
        let providerCode = try ProviderCreator.createActionProvider(prefix: "Default", actions: actions).formatted().description
        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")
        print(providerCode)
        print("=========================")
        XCTAssertEqual(
            providerCode,
            """
            import Nativeblocks
            public class DefaultActionProvider {
                public static func provideActions(nativeAlert : NativeAlert) {
                    NativeblocksManager.getInstance().provideAction(actionKeyType: "ALERT", action: NativeAlertAction(action: nativeAlert))
                }
            }
            """
        )
    }

    func testBlockProviderGenerator() throws {
        let sources = [
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
            """
        ]

        let (blocks, _) = NativeBlockVisitor.extractNatives(from: sources)
        let providerCode = try ProviderCreator.createBlockProvider(prefix: "Default", blocks: blocks).formatted().description
        print("-------------------------")
        for source in sources {
            print(source)
        }
        print("+++++++++++++++++++++++++")
        print(providerCode)
        print("=========================")
        XCTAssertEqual(
            providerCode,
            """
            import Nativeblocks
            public class DefaultBlockProvider {
                public static func provideBlocks() {
                    NativeblocksManager.getInstance().provideBlock(blockKeyType: "MYText", block: MyTextBlock())
                    NativeblocksManager.getInstance().provideBlock(blockKeyType: "MYText2", block: MyText2Block())
                }
            }
            """
        )
    }
}
