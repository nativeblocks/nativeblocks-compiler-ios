import SwiftSyntax

public protocol NativeMeta: Encodable {}

public enum NativeKind {
    case action
    case block
}

public struct DataMeta: NativeMeta {
    public var position: Int
    public var key: String
    public var type: String
    public var description: String
    public var block: AttributeSyntax?
    public var variable: PatternBindingSyntax?

    init(
        position: Int,
        key: String,
        type: String,
        description: String,
        block: AttributeSyntax? = nil,
        variable: PatternBindingSyntax? = nil
    ) {
        self.position = position
        self.key = key
        self.type = type
        self.description = description
        self.block = block
        self.variable = variable
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.key, forKey: .key)
        try container.encode(TypeUtils.typeMapToJson(self.type)!, forKey: .type)
        try container.encode(self.description, forKey: .description)
    }

    private enum CodingKeys: String, CodingKey {
        case key, type, description
    }
}

public struct ValuePickerOption: Encodable {
    public var id: String
    public var text: String
}

public struct PropertyMeta: NativeMeta {
    public var position: Int
    public var key: String
    public var value: String
    public var type: String
    public var description: String
    public var valuePicker: String
    public var valuePickerOptions: [ValuePickerOption]
    public var valuePickerGroup: String
    public var block: AttributeSyntax?
    public var variable: PatternBindingSyntax?

    init(
        position: Int,
        key: String,
        value: String,
        type: String,
        description: String,
        valuePicker: String,
        valuePickerOptions: [ValuePickerOption],
        valuePickerGroup: String,
        block: AttributeSyntax? = nil,
        variable: PatternBindingSyntax? = nil
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
        self.variable = variable
    }

    private enum CodingKeys: String, CodingKey {
        case key, type, description, value, valuePicker, valuePickerGroup, valuePickerOptions
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.key, forKey: .key)
        try container.encode(TypeUtils.typeMapToJson(self.type)!, forKey: .type)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.value, forKey: .value)
        try container.encode(TypeUtils.valuePickerMapJson(self.valuePicker), forKey: .valuePicker)
        try container.encode(self.valuePickerGroup, forKey: .valuePickerGroup)
        try container.encode(TypeUtils.valuePickerOptionsMapToJson(self.valuePickerOptions), forKey: .valuePickerOptions)
    }
}

public struct EventMeta: NativeMeta {
    public var kind: NativeKind
    public var position: Int
    public var event: String
    public var description: String
    public var dataBinding: [String] = []
    public var isOptinalFunction: Bool
    public var then: String?
    public var block: AttributeSyntax?
    public var variable: PatternBindingSyntax?

    init(
        kind: NativeKind,
        position: Int,
        event: String,
        description: String,
        dataBinding: [String],
        isOptinalFunction: Bool,
        then: String? = nil,
        block: AttributeSyntax? = nil,
        variable: PatternBindingSyntax? = nil
    ) {
        self.kind = kind
        self.position = position
        self.event = event
        self.description = description
        self.dataBinding = dataBinding
        self.then = then
        self.isOptinalFunction = isOptinalFunction
        self.block = block
        self.variable = variable
    }

    private enum CodingKeys: String, CodingKey {
        case event, description
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if self.kind == .action {
            try container.encode(TypeUtils.thenMapToJson(self.then), forKey: .event)
        } else {
            try container.encode(self.event, forKey: .event)
        }
        try container.encode(self.description, forKey: .description)
    }
}

public struct SlotMeta: NativeMeta {
    public var position: Int
    public var slot: String
    public var description: String
    public var hasBlockIndex: Bool
    public var isOptinalFunction: Bool
    public var block: AttributeSyntax?
    public var variable: PatternBindingSyntax?

    init(
        position: Int,
        slot: String,
        description: String,
        hasBlockIndex: Bool,
        isOptinalFunction: Bool,
        block: AttributeSyntax? = nil,
        variable: PatternBindingSyntax? = nil
    ) {
        self.position = position
        self.slot = slot
        self.description = description
        self.hasBlockIndex = hasBlockIndex
        self.isOptinalFunction = isOptinalFunction
        self.block = block
        self.variable = variable
    }

    private enum CodingKeys: String, CodingKey {
        case slot, description
    }
}

public struct ActionMeta: NativeMeta {
    public var parameterClass: String
    public var functionName: String
    public var functionParamName: String
    public var isAsync: Bool

    init(parameterClass: String, functionName: String, functionParamName: String, isAsync: Bool) {
        self.parameterClass = parameterClass
        self.functionName = functionName
        self.functionParamName = functionParamName
        self.isAsync = isAsync
    }
}
