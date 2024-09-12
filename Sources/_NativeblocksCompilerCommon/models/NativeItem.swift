import SwiftSyntax

public protocol NativeItem: Encodable {}

public struct NativeBlock: NativeItem {
    public var declName: String
    public var name: String
    public var keyType: String
    public var description: String
    public var syntax: StructDeclSyntax
    public var meta: [NativeMeta]
    public let kind = "BLOCK"
    public let price = 0
    public let platFormSupport = "IOS"
    public let imageIcon = ""
    public let documentation = ""

    private enum CodingKeys: String, CodingKey {
        case name, description, documentation, imageIcon, keyType, kind, platFormSupport, price
    }
}

public struct NativeAction: NativeItem {
    public var declName: String
    public var name: String
    public var keyType: String
    public var description: String
    public var syntax: ClassDeclSyntax
    public var meta: [NativeMeta]
    public let kind = "ACTION"
    public let price = 0
    public let platFormSupport = "IOS"
    public let imageIcon = ""
    public let documentation = ""

    private enum CodingKeys: String, CodingKey {
        case name, description, documentation, imageIcon, keyType, kind, platFormSupport, price
    }
}
