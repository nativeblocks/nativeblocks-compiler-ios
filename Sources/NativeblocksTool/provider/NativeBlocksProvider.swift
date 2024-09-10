import Foundation
import SwiftParser
import SwiftSyntax

public class NativeBlocksProvider {
    var filePaths: [URL] = []
    
    var target :String? = nil
    
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
    
    func addTarget(at target:String){
        self.target = target
    }
    
    public func processAll() throws {
        let files = filePaths.compactMap { filePath in
            try? String(contentsOf: filePath, encoding: .utf8)
        }
        print("processAll count:\(files.count)")
        var name = "DefaultNativeblocksProvider"
        if target != nil {
            name = toCamelCaseWithoutSpaces(target!) + "NativeblocksProvider"
        }
        let provider = try processFiles(files: files, name:name)
        let code = provider.formatted().description
        let filePath = FileManager.default.currentDirectoryPath + "/\(name).swift"
        try code.write(toFile: filePath, atomically: true, encoding: .utf8)
        print(provider.formatted().description)
    }
    
    public func processFiles(files: [String], name: String) throws -> SourceFileSyntax {
        let natives = try files.flatMap { file in try nativeExtractor(at: file) }
        
        let blocks = natives.compactMap { $0 as? NativeBlock }
        let actions = natives.compactMap { $0 as? NativeAction }
        
        let provider = try NativeProviderGenerator.generateProvider(prefix: name, blocks: blocks, actions: actions)
        
        return provider
    }
    
    public func nativeExtractor(at file: String) throws -> [NativeItem] {
        let sourceFile = Parser.parse(source: file)
        let nativeBlockVisitor = NativeBlockVisitor(viewMode: SyntaxTreeViewMode.sourceAccurate)
        nativeBlockVisitor.walk(sourceFile)
        return nativeBlockVisitor.nativeBlocks
    }
    
    
    
    func toCamelCaseWithoutSpaces(_ input: String) -> String {
        // Convert the first letter to lowercase
        guard !input.isEmpty else { return "" }
        
        let firstCharacter = input.prefix(1).uppercased()
        let remainingCharacters = input.dropFirst()
        
        // Combine the lowercase first character with the remaining part of the string
        return firstCharacter + remainingCharacters
    }
}
