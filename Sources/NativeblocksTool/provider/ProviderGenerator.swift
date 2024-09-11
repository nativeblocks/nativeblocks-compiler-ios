import Foundation
import NativeblocksCompilerCommon
import SwiftParser
import SwiftSyntax

public class ProviderGenerator {
    var filePaths: [URL] = []
    var prefix: String
    
    public init(prefix: String, from directory: URL) throws {
        self.prefix = prefix
        try getFiles(from: directory)
    }
    
    private func getFiles(from directory: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for url in contents {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                try getFiles(from: url)
            } else if url.pathExtension == "swift" {
                print(url.absoluteString)
                filePaths.append(url)
            }
        }
    }
    
    public func generate() throws {
        let files = filePaths.compactMap { filePath in
            try? String(contentsOf: filePath, encoding: .utf8)
        }
        
        let name = generateName(prefix: prefix)
        
        let (blocks, actions) = NativeBlockVisitor.extractNatives(from: files)
      
        let actionProviderCode = try ProviderCreator.createActionProvider(prefix: name, actions: actions).formatted().description
        
        let blockProviderCode = try ProviderCreator.createBlockProvider(prefix: prefix, blocks: blocks).formatted().description
        
        let actionFilePath = FileManager.default.currentDirectoryPath + "/\(name)ActionProvider.swift"
        let blockFilePath = FileManager.default.currentDirectoryPath + "/\(name)BlockProvider.swift"
        
        try actionProviderCode.write(toFile: actionFilePath, atomically: true, encoding: .utf8)
        try blockProviderCode.write(toFile: blockFilePath, atomically: true, encoding: .utf8)
        
        print(actionProviderCode)
        print(blockProviderCode)
    }
    
    func generateName(prefix: String?) -> String {
        guard ((prefix?.isEmpty) != nil) == true else { return "Default" }
        let firstCharacter = prefix!.prefix(1).uppercased()
        let remainingCharacters = prefix!.dropFirst()
        return firstCharacter + remainingCharacters
    }
}
