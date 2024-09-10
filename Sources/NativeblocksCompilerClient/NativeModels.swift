import SwiftSyntax

public protocol NativeItem{
    
}

public struct NativeBlock : NativeItem {
    var name:String
    var syntax: StructDeclSyntax
    
}

public struct NativeAction : NativeItem {
    var name:String
    var syntax: ClassDeclSyntax
}
