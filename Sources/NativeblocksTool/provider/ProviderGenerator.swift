import _NativeblocksCompilerCommon
import Foundation
import SwiftParser
import SwiftSyntax

public class ProviderGenerator {
    var prefix: String
    
    public var actionProviderCode: String?
    public var blockProviderCode: String?
    
    public init(prefix: String) {
        self.prefix = ProviderGenerator.generateName(prefix: prefix)
    }

    public func generate(from files: [String]) throws {
        let (blocks, actions) = NativeBlockVisitor.extractNatives(from: files)
        
        actionProviderCode = try ProviderCreator.createActionProvider(prefix: prefix, actions: actions).formatted().description
        
        blockProviderCode = try ProviderCreator.createBlockProvider(prefix: prefix, blocks: blocks).formatted().description
    }
    
    public func save(to directory: URL) throws {
        let actionFilePath = directory.absoluteString + "/\(prefix)ActionProvider.swift"
        let blockFilePath = directory.absoluteString + "/\(prefix)BlockProvider.swift"
        
        try actionProviderCode!.write(toFile: actionFilePath, atomically: true, encoding: .utf8)
        try blockProviderCode!.write(toFile: blockFilePath, atomically: true, encoding: .utf8)
    }
    
    static func generateName(prefix: String?) -> String {
        guard ((prefix?.isEmpty) != nil) == true else { return "Default" }
        let firstCharacter = prefix!.prefix(1).uppercased()
        let remainingCharacters = prefix!.dropFirst()
        return firstCharacter + remainingCharacters
    }
}
