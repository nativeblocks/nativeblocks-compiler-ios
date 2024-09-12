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
            integrationString,
            """
            {"platFormSupport":"IOS","documentation":"","keyType":"ALERT","price":0,"description":"Nativeblocks alert action","imageIcon":"","name":"Alert","kind":"ACTION"}
            """
        )
        XCTAssertEqual(
            datasString,
            """
            [{"key":"message","type":"STRING","description":""}]
            """
        )
        XCTAssertEqual(
            eventsString,
            """
            [{"event":"END","description":""}]
            """
        )
        XCTAssertEqual(
            propertiesString,
            """
            [{"value":"false","key":"animated","type":"BOOLEAN","description":""}]
            """
        )
    }
    
    func testBlockJsonGenerator() throws {
        let sources = [
            """
            @NativeBlock(name: "My text", keyType: "MYText", description: "text description")
            struct MyText {
                @NativeBlockData(description: "desc text")
                var text: String
                @NativeBlockProp(description: "desc number")
                var number: Int
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
            integrationString,
            """
            {"platFormSupport":"IOS","documentation":"","keyType":"MYText","price":0,"description":"text description","imageIcon":"","name":"My text","kind":"BLOCK"}
            """
        )
        XCTAssertEqual(
            datasString,
            """
            [{"key":"text","type":"STRING","description":"desc text"}]
            """
        )
        XCTAssertEqual(
            eventsString,
            """
            []
            """
        )
        XCTAssertEqual(
            propertiesString,
            """
            [{"value":"","key":"number","type":"INT","description":"desc number"}]
            """
        )
        XCTAssertEqual(
            slotsString,
            """
            []
            """
        )
    }
}
