import Foundation
import SwiftParser
import SwiftSyntax

public class NativeBlocksProvider {
    var filePaths: [URL] = []
    
    var target: String?
    
    public init() {}
    
    func addDirectory(at directory: URL) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for url in contents {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                try addDirectory(at: url)
            } else if url.pathExtension == "swift" {
                print(url.absoluteString)
                filePaths.append(url)
            }
        }
    }
    
    func addTarget(at target: String) {
        self.target = target
    }
    
    public func processAll() throws {
        let files = filePaths.compactMap { filePath in
            try? String(contentsOf: filePath, encoding: .utf8)
        }
        
        let name = generateName(target: target)
        
        let (blocks, actions) = extractNatives(from: files)

        let actionProviderCode = try generateActionProvider(actions: actions, prefix: name)
        let blockProviderCode = try generateBlockProvider(blocks: blocks, prefix: name)
        
        let actionFilePath = FileManager.default.currentDirectoryPath + "/\(name)ActionProvider.swift"
        let blockFilePath = FileManager.default.currentDirectoryPath + "/\(name)BlockProvider.swift"
        
        try actionProviderCode.write(toFile: actionFilePath, atomically: true, encoding: .utf8)
        try blockProviderCode.write(toFile: blockFilePath, atomically: true, encoding: .utf8)
        
        print(actionProviderCode)
        print(blockProviderCode)
    }
    
    public func extractNatives(from sources: [String]) -> ([NativeBlock], [NativeAction]) {
        let nativeBlockVisitor = NativeBlockVisitor(viewMode: SyntaxTreeViewMode.sourceAccurate)
        
        for source in sources {
            let sourceFile = Parser.parse(source: source)
            nativeBlockVisitor.walk(sourceFile)
        }
        
        let natives = nativeBlockVisitor.nativeBlocks
        
        let blocks = natives.compactMap { $0 as? NativeBlock }
        let actions = natives.compactMap { $0 as? NativeAction }
        return (blocks, actions)
    }
    
    public func generateActionProvider(actions: [NativeAction], prefix: String) throws -> String {
        let provider = try NativeProviderGenerator.generateActionProvider(prefix: prefix, actions: actions)
        return provider.formatted().description
    }
    
    public func generateBlockProvider(blocks: [NativeBlock], prefix: String) throws -> String {
        let provider = try NativeProviderGenerator.generateBlockProvider(prefix: prefix, blocks: blocks)
        return provider.formatted().description
    }
    
    func generateName(target: String?) -> String {
        guard ((target?.isEmpty) != nil) == true else { return "Default" }
        let firstCharacter = target!.prefix(1).uppercased()
        let remainingCharacters = target!.dropFirst()
        return firstCharacter + remainingCharacters
    }
}
