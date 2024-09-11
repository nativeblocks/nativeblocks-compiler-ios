import SwiftSyntax

public protocol NativeItem {}

public struct NativeBlock: NativeItem {
    public var declName: String
    public var name: String
    public var keyType: String
    public var description: String
    public var syntax: StructDeclSyntax
}

public struct NativeAction: NativeItem {
    public var declName: String
    public var name: String
    public var keyType: String
    public var description: String
    public var syntax: ClassDeclSyntax
}
