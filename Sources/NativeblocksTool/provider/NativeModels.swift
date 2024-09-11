import SwiftSyntax

public protocol NativeItem {}

public struct NativeBlock: NativeItem {
    var declName: String
    var name: String
    var keyType: String
    var description: String
    var syntax: StructDeclSyntax
}

public struct NativeAction: NativeItem {
    var declName: String
    var name: String
    var keyType: String
    var description: String
    var syntax: ClassDeclSyntax
}
