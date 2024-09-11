import SwiftSyntax

public protocol NativeMeta {}

public struct DataNativeMeta: NativeMeta {
    public var position: Int
    public var key: String
    public var type: String
    public var description: String
    public var block: AttributeSyntax?
    public var valriable: PatternBindingSyntax?

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

public struct PropertyNativeMeta: NativeMeta {
    public var position: Int
    public var key: String
    public var value: String
    public var type: String
    public var description: String
    public var valuePicker: String
    public var valuePickerOptions: String
    public var valuePickerGroup: String
    public var block: AttributeSyntax?
    public var valriable: PatternBindingSyntax?

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

public struct EventNativeMeta: NativeMeta {
    public var position: Int
    public var event: String
    public var description: String
    public var dataBinding: [String] = []
    public var isOptinalFunction: Bool
    public var then: String?
    public var block: AttributeSyntax?
    public var valriable: PatternBindingSyntax?

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

public struct SlotNativeMeta: NativeMeta {
    public var position: Int
    public var slot: String
    public var description: String
    public var hasBlockIndex: Bool
    public var isOptinalFunction: Bool
    public var block: AttributeSyntax?
    public var valriable: PatternBindingSyntax?

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

public struct ActionNativeMeta: NativeMeta {
    public var parameterClass: String
    public var functionName: String
    public var functionParamName: String

    init(parameterClass: String, functionName: String, functionParamName: String) {
        self.parameterClass = parameterClass
        self.functionName = functionName
        self.functionParamName = functionParamName
    }
}
