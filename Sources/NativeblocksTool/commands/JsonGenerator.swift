import _NativeblocksCompilerCommon
import Foundation
import SwiftParser
import SwiftSyntax

public class JsonGenerator {
    public var blocksJson: [String: [JsonGenerateType: String]] = [:]
    public var actionsJson: [String: [JsonGenerateType: String]] = [:]
    

    public init() {}

    public func generate(from files: [String],organizationId:String = "") throws {
        print("Generate jsons...")
        var (blocks, actions) = NativeBlockVisitor.extractNatives(from: files)
        
        if blocks.isEmpty && actions.isEmpty {
            print("There is no actions or blocks to generate")
            return
        }
        
        blocks = blocks.map { block in
            let (meta, _) = BlockExtractor.extractVariable(from: block.syntax)
            var copy = block
            copy.meta = meta
            copy.organizationId = organizationId
            return copy
        }
        
        actions = actions.map { action in
            let (meta, _) = ActionExtractor.extractVariable(from: action.syntax)
            var copy = action
            copy.meta = meta
            copy.organizationId = organizationId
            return copy
        }
        
        blocksJson = try Dictionary(uniqueKeysWithValues: blocks.map { block in
            print("generate Json \(block.keyType) Block")
            
            let jsonList = try generateBlock(from: block)
            
            return (block.keyType, jsonList)
        })
        
        actionsJson = try Dictionary(uniqueKeysWithValues: actions.map { action in
            print("generate Json \(action.keyType) Action")
            
            let jsonList = try generateAction(from: action)
            
            return (action.keyType, jsonList)
        })
    }
    
    public func save(to directory: String, with fileManager: FileManager, prefix: String = "/.nativeblocks") throws {
        print("Save jsons...")
        
        if blocksJson.isEmpty && actionsJson.isEmpty {
            print("There is no actions or blocks to save")
            return
        }
        
        let baseDirectory = "\(directory)\(prefix)"
        
        try? fileManager.deleteDirectory(atPath: baseDirectory)
        
        try fileManager.createDirectory(atPath: baseDirectory)
        
        for block in blocksJson {
            let blockDirectory = "\(baseDirectory)/block/\(block.key)"
            print("save Json \(block.key) Block at:\(blockDirectory)")
            
            try fileManager.createDirectory(atPath: blockDirectory)
            
            try saveJsons(jsons: block.value, in: blockDirectory)
        }
        
        for action in actionsJson {
            let directory = "\(baseDirectory)/action/\(action.key)"
            
            print("save Json \(action.key) Action at:\(directory)")
            
            try fileManager.createDirectory(atPath: directory)
            
            try saveJsons(jsons: action.value, in: directory)
        }
    }
    
    public func upload(endpoint: URL, authToken: String, organizationId: String) throws {
        
        
        
    }
    
    public func generateBlock(from block: NativeBlock) throws -> [JsonGenerateType: String] {
        var export: [JsonGenerateType: String] = [:]
        
        export[JsonGenerateType.integration] = try String(data: JSONEncoder().encode(block), encoding: .utf8)
        
        let datas = block.meta.compactMap { $0 as? DataNativeMeta }
        let events = block.meta.compactMap { $0 as? EventNativeMeta }
        let properties = block.meta.compactMap { $0 as? PropertyNativeMeta }
        let slots = block.meta.compactMap { $0 as? SlotNativeMeta }
        
        export[JsonGenerateType.data] = try String(data: JSONEncoder().encode(datas), encoding: .utf8)
        export[JsonGenerateType.event] = try String(data: JSONEncoder().encode(events), encoding: .utf8)
        export[JsonGenerateType.propertie] = try String(data: JSONEncoder().encode(properties), encoding: .utf8)
        export[JsonGenerateType.slot] = try String(data: JSONEncoder().encode(slots), encoding: .utf8)
        
        return export
    }
    
    public func generateAction(from action: NativeAction) throws -> [JsonGenerateType: String] {
        var export: [JsonGenerateType: String] = [:]
        
        export[JsonGenerateType.integration] = try String(data: JSONEncoder().encode(action), encoding: .utf8)
        
        let datas = action.meta.compactMap { $0 as? DataNativeMeta }
        let events = action.meta.compactMap { $0 as? EventNativeMeta }
        let properties = action.meta.compactMap { $0 as? PropertyNativeMeta }
        
        export[JsonGenerateType.data] = try String(data: JSONEncoder().encode(datas), encoding: .utf8)
        export[JsonGenerateType.event] = try String(data: JSONEncoder().encode(events), encoding: .utf8)
        export[JsonGenerateType.propertie] = try String(data: JSONEncoder().encode(properties), encoding: .utf8)
        
        return export
    }
    
    private func saveJsons(jsons: [JsonGenerateType: String], in directory: String) throws {
        try jsons.forEach { (type: JsonGenerateType, json: String) in
            print("/\(type.fileName) ==> \(json))")
            try json.write(toFile: directory + "/\(type.fileName)", atomically: true, encoding: .utf8)
        }
    }
}

public enum JsonGenerateType {
    case integration
    case data
    case event
    case propertie
    case slot
    
   public var fileName: String {
        switch self {
        case .integration:
            return "integration.json"
        case .data:
            return "data.json"
        case .event:
            return "events.json"
        case .propertie:
            return "properties.json"
        case .slot:
            return "slots.json"
        }
    }
}
