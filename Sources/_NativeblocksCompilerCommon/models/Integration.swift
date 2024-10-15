import SwiftSyntax

public struct Integration: Encodable {
    public var declName: String
    public var name: String
    public var keyType: String
    public var description: String
    public var syntaxStruct: StructDeclSyntax? = nil
    public var syntaxClass: ClassDeclSyntax? = nil
    public var meta: [NativeMeta]
    public let kind: String
    public let price = 0
    public let platformSupport = "IOS"
    public let imageIcon = ""
    public let documentation = ""
    public var organizationId = ""
    public var `public` = false

    private enum CodingKeys: String, CodingKey {
        case name, 
             description,
             documentation,
             imageIcon,
             keyType,
             kind,
             platformSupport,
             price,
             organizationId,
             `public`
    }
}
