import Foundation

public class NativeblocksToolExecutor {
    var target: String?
    var directory: URL?
    public init(_ arguments: [String]) throws {
        (self.target, self.directory) = try parseAndValidateArguments(arguments)
    }

    public func execute() throws {
        let provider = NativeBlocksProvider()

        try provider.addDirectory(at: directory!)
        provider.addTarget(at: target!)
        try provider.processAll()
    }

    private func parseAndValidateArguments(_ arguments: [String]) throws -> (target: String, directory: URL) {
        var parsedArgs: [String: String] = [:]

        var currentArgKey: String?
        for argument in arguments {
            if argument.starts(with: "--") {
                currentArgKey = argument
            } else if let currentKey = currentArgKey {
                parsedArgs[currentKey] = argument
                currentArgKey = nil
            }
        }

        guard let target = parsedArgs["--target"] else {
            throw ArgumentError.missingTarget
        }

        guard let directoryPath = parsedArgs["--directory"] else {
            throw ArgumentError.missingDirectory
        }

        let directoryURL = URL(fileURLWithPath: directoryPath)
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            throw ArgumentError.invalidDirectory(directoryPath)
        }

        let validArgs = Set(["--target", "--directory"])
        let extraArgs = parsedArgs.keys.filter { !validArgs.contains($0) }
        if !extraArgs.isEmpty {
            throw ArgumentError.extraArguments(extraArgs)
        }

        return (target, directoryURL)
    }
}
