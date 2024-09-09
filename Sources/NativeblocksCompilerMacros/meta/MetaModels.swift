import SwiftSyntax

struct Data: BlockVariable {
    var position: Int
    var key: String
    var type: String
    var description: String
    var block: AttributeSyntax?
    var valriable: PatternBindingSyntax?

    init(
        position: Int, key: String, type: String, description: String, block: AttributeSyntax? = nil, valriable: PatternBindingSyntax? = nil
    ) {
        self.position = position
        self.key = key
        self.type = type
        self.description = description
        self.block = block
        self.valriable = valriable
    }
}

struct Property: BlockVariable {
    var position: Int
    var key: String
    var value: String
    var type: String
    var description: String
    var valuePicker: String
    var valuePickerOptions: String
    var valuePickerGroup: String
    var block: AttributeSyntax?
    var valriable: PatternBindingSyntax?

    init(
        position: Int, key: String, value: String, type: String, description: String, valuePicker: String, valuePickerOptions: String,
        valuePickerGroup: String, block: AttributeSyntax? = nil, valriable: PatternBindingSyntax? = nil
    ) {
        self.position = position
        self.key = key
        self.value = value
        self.type = type
        self.description = description
        self.valuePicker = valuePicker
        self.valuePickerOptions = valuePickerOptions
        self.valuePickerGroup = valuePickerGroup
        self.block = block
        self.valriable = valriable
    }
}

struct Event: BlockVariable {
    var position: Int
    var event: String
    var description: String
    var dataBinding: [String] = []
    var isOptinalFunction: Bool
    var then: String?
    var block: AttributeSyntax?
    var valriable: PatternBindingSyntax?

    init(
        position: Int, event: String, description: String, dataBinding: [String], isOptinalFunction: Bool, then: String? = nil,
        block: AttributeSyntax? = nil,
        valriable: PatternBindingSyntax? = nil
    ) {
        self.position = position
        self.event = event
        self.description = description
        self.dataBinding = dataBinding
        self.then = then
        self.isOptinalFunction = isOptinalFunction
        self.block = block
        self.valriable = valriable
    }
}

struct Slot: BlockVariable {
    var position: Int
    var slot: String
    var description: String
    var hasBlockIndex: Bool
    var isOptinalFunction: Bool
    var block: AttributeSyntax?
    var valriable: PatternBindingSyntax?

    init(
        position: Int, slot: String, description: String, hasBlockIndex: Bool, isOptinalFunction: Bool, block: AttributeSyntax? = nil,
        valriable: PatternBindingSyntax? = nil
    ) {
        self.position = position
        self.slot = slot
        self.description = description
        self.hasBlockIndex = hasBlockIndex
        self.isOptinalFunction = isOptinalFunction
        self.block = block
        self.valriable = valriable
    }
}

struct ActionInfo: BlockVariable {
    var parameterClass: String
    var functionName: String
    var functionParamName: String

    init(parameterClass: String, functionName: String, functionParamName: String) {
        self.parameterClass = parameterClass
        self.functionName = functionName
        self.functionParamName = functionParamName
    }

}

protocol BlockVariable {}
