import Foundation
import SwiftParser
import SwiftSyntax

public class NativeBlocksProvider {
    var filePaths: [URL] = []
    
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
    
    public func processAll() throws {
        let files = filePaths.compactMap { filePath in
            try? String(contentsOf: filePath, encoding: .utf8)
        }
        print("processAll count:\(files.count)")
        let provider = try processFiles(files: files)
        let code = provider.formatted().description
        let filePath = FileManager.default.currentDirectoryPath + "/Provider.swift"
        try code.write(toFile: filePath, atomically: true, encoding: .utf8)
        print(provider.formatted().description)
    }
    
    public func processFiles(files: [String]) throws -> SourceFileSyntax {
        let natives = try files.flatMap { file in try nativeExtractor(at: file) }
        
        let blocks = natives.compactMap { $0 as? NativeBlock }
        let actions = natives.compactMap { $0 as? NativeAction }
        
        let provider = try NativeProviderGenerator.generateProvider(prefix: "Default", blocks: blocks, actions: actions)
        
        return provider
    }
    
    public func nativeExtractor(at file: String) throws -> [NativeItem] {
        let sourceFile = Parser.parse(source: file)
        let nativeBlockVisitor = NativeBlockVisitor(viewMode: SyntaxTreeViewMode.sourceAccurate)
        nativeBlockVisitor.walk(sourceFile)
        return nativeBlockVisitor.nativeBlocks
    }
}
