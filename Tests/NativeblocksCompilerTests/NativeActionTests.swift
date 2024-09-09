import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(NativeblocksCompilerMacros)
    import NativeblocksCompilerMacros

    let testActionMacros: [String: Macro.Type] = [
        "NativeAction": NativeActionMacro.self
    ]

#endif

final class NativeActionTests: XCTestCase {
    func testNativeAction() throws {
        #if canImport(NativeblocksCompilerMacros)
            assertMacroExpansion(
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
                        @NativeActionEvent(then: Then.SUCCESS)
                        var completion: () -> Void
                    }

                    @NativeActionFunction
                    func callAsFunction(
                        param: Parameter
                    ) {
                        alertController.message = param.message
                        alertController.present(
                            animated: param.animated,
                            completion: { param.completion() }
                        )
                    }
                }
                """,
                expandedSource:
                    """
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
                            @NativeActionEvent(then: Then.SUCCESS)
                            var completion: () -> Void
                        }

                        @NativeActionFunction
                        func callAsFunction(
                            param: Parameter
                        ) {
                            alertController.message = param.message
                            alertController.present(
                                animated: param.animated,
                                completion: { param.completion() }
                            )
                        }
                    }

                    public class NativeAlertAction: INativeAction {
                        var action: NativeAlert
                        init(action: NativeAlert) {
                            self.action = action
                        }
                        public func handle(actionProps: ActionProps) {
                            let data = actionProps.trigger?.data ?? [:]
                            let properties = actionProps.trigger?.properties ?? [:]
                            let messageData = actionProps.variables? [data["message"]?.value ?? ""]
                            let animatedProp = Bool(properties["animated"]?.value ?? "") ??  false
                            let param = NativeAlert.Parameter(
                                message: messageData?.value ?? "",
                                animated: animatedProp,
                                completion: {

                                    if actionProps.trigger != nil {
                                        actionProps.onHandleSuccessNextTrigger?(actionProps.trigger!)
                                    }
                                })
                            action.callAsFunction(param: param)
                        }
                    }
                    """,

                macros: testActionMacros
            )

        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

}
