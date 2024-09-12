import _NativeblocksCompilerCommon
import Foundation
import SwiftParser
import SwiftSyntax

public class JsonGenerator {
    public var blocks: [NativeBlock] = []
    public var actions: [NativeAction] = []
    
    public init() {}

    public func generate(from files: [String]) throws {
        (blocks, actions) = NativeBlockVisitor.extractNatives(from: files)
        
        blocks = blocks.map { block in
            let (meta, _) = BlockExtractor.extractVariable(from: block.syntax)
            var copy = block
            copy.meta = meta
            return copy
        }
        
        actions = actions.map { action in
            let (meta, _) = ActionExtractor.extractVariable(from: action.syntax)
            var copy = action
            copy.meta = meta
            return copy
        }
    }
    
    public func save(to directory: String, with fileManager: FileManager, prefix: String = "/.nativeblocks") throws {
        let baseDirectory = "\(directory)\(prefix)"
        
        try? fileManager.deleteDirectory(atPath: baseDirectory)
        
        try fileManager.createDirectory(atPath: baseDirectory)
        
        for block in blocks {
            let blockDirectory = "\(baseDirectory)/block/\(block.keyType)"
            print("Block : name:\(block.name) at :\(blockDirectory)")
            
            try fileManager.createDirectory(atPath: blockDirectory)
            
            let (integrationString, datasString, eventsString, propertiesString, slotsString) = try generateBlock(from: block)
            
            try saveBlock(
                integrationString: integrationString,
                datasString: datasString,
                eventsString: eventsString,
                propertiesString: propertiesString,
                slotsString: slotsString,
                in: blockDirectory
            )
        }
        
        for action in actions {
            let actionDirectory = "\(baseDirectory)/action/\(action.keyType)"
            print("Action : name:\(action.name) at :\(actionDirectory)")
            
            try fileManager.createDirectory(atPath: actionDirectory)
            
            let (integrationString, datasString, eventsString, propertiesString) = try generateAction(from: action)
            
            try saveAction(
                integrationString: integrationString,
                datasString: datasString,
                eventsString: eventsString,
                propertiesString: propertiesString,
                in: actionDirectory
            )
        }
    }
    
    public func generateBlock(from block: NativeBlock) throws -> (integration: String?, data: String?, events: String?, properties: String?, slots: String?) {
        let integrationString = try String(data: JSONEncoder().encode(block), encoding: .utf8)
        
        let datas = block.meta.compactMap { $0 as? DataNativeMeta }
        let events = block.meta.compactMap { $0 as? EventNativeMeta }
        let properties = block.meta.compactMap { $0 as? PropertyNativeMeta }
        let slots = block.meta.compactMap { $0 as? SlotNativeMeta }
        
        let datasString = try String(data: JSONEncoder().encode(datas), encoding: .utf8)
        let eventsString = try String(data: JSONEncoder().encode(events), encoding: .utf8)
        let propertiesString = try String(data: JSONEncoder().encode(properties), encoding: .utf8)
        let slotsString = try String(data: JSONEncoder().encode(slots), encoding: .utf8)
        
        return (integrationString, datasString, eventsString, propertiesString, slotsString)
    }
    
    public func generateAction(from action: NativeAction) throws -> (integration: String?, data: String?, events: String?, properties: String?) {
        let integrationString = try String(data: JSONEncoder().encode(action), encoding: .utf8)
        
        let datas = action.meta.compactMap { $0 as? DataNativeMeta }
        let events = action.meta.compactMap { $0 as? EventNativeMeta }
        let properties = action.meta.compactMap { $0 as? PropertyNativeMeta }
        
        let datasString = try String(data: JSONEncoder().encode(datas), encoding: .utf8)
        let eventsString = try String(data: JSONEncoder().encode(events), encoding: .utf8)
        let propertiesString = try String(data: JSONEncoder().encode(properties), encoding: .utf8)
        return (integrationString, datasString, eventsString, propertiesString)
    }
    
    private func saveBlock(integrationString: String?, datasString: String?, eventsString: String?, propertiesString: String?, slotsString: String?, in directory: String) throws {
        print("/integration.json ==> \(String(integrationString ?? ""))")
        print("/data.json ==> \(String(datasString ?? ""))")
        print("/events.json ==> \(String(eventsString ?? ""))")
        print("/properties.json ==> \(String(propertiesString ?? ""))")
        print("/slots.json ==> \(String(slotsString ?? ""))")
        
        try integrationString?.write(toFile: directory + "/integration.json", atomically: true, encoding: .utf8)
        try datasString?.write(toFile: directory + "/data.json", atomically: true, encoding: .utf8)
        try eventsString?.write(toFile: directory + "/events.json", atomically: true, encoding: .utf8)
        try propertiesString?.write(toFile: directory + "/properties.json", atomically: true, encoding: .utf8)
        try slotsString?.write(toFile: directory + "/slots.json", atomically: true, encoding: .utf8)
    }
    
    private func saveAction(integrationString: String?, datasString: String?, eventsString: String?, propertiesString: String?, in directory: String) throws {
        print("/integration.json ==> \(String(describing: integrationString))")
        print("/data.json ==> \(String(describing: datasString))")
        print("/events.json ==> \(String(describing: eventsString))")
        print("/properties.json ==> \(String(describing: propertiesString))")
        
        try integrationString?.write(toFile: directory + "/integration.json", atomically: true, encoding: .utf8)
        try datasString?.write(toFile: directory + "/data.json", atomically: true, encoding: .utf8)
        try eventsString?.write(toFile: directory + "/events.json", atomically: true, encoding: .utf8)
        try propertiesString?.write(toFile: directory + "/properties.json", atomically: true, encoding: .utf8)
    }
}
