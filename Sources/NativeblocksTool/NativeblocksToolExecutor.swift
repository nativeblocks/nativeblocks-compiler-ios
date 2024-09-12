import Foundation

public class NativeblocksToolExecutor {
    let GenerateProviderCommand = "generate-provider"
    let GenerateJsonCommand = "generate-json"
    let TargetArgumentKey = "--target"
    let DirectoryArgumentKey = "--directory"

    var parsedArgs: [String: String] = [:]
    var commands: [String] = []

    public init(_ arguments: [String]) throws {
        (commands, parsedArgs) = try parseArguments(arguments)
        try validateArguments(commands: commands, parsedArgs: parsedArgs)
    }

    public func execute() throws {
        if commands.isEmpty {
            throw ArgumentError.missingCommand
        }

        if commands.contains(where: { command in command == GenerateProviderCommand }) {
            let directory = URL(fileURLWithPath: parsedArgs[DirectoryArgumentKey]!)
            let output = FileManager.default.currentDirectoryPath
            let files = try FileUtils.getFilesContent(from: directory)
            let target = parsedArgs[TargetArgumentKey]!
            let generator = ProviderGenerator(prefix: target)
            try generator.generate(from: files)
            try generator.save(to: output)
        }

        if commands.contains(where: { command in command == GenerateJsonCommand }) {}
    }

    private func parseArguments(_ arguments: [String]) throws -> (commands: [String], parsedArgs: [String: String]) {
        var parsedArgs: [String: String] = [:]
        var commands: [String] = []
        var currentArgKey: String?
        for argument in arguments {
            if argument.starts(with: "--") {
                currentArgKey = argument
            } else if let currentKey = currentArgKey {
                parsedArgs[currentKey] = argument
                currentArgKey = nil
            } else if argument == GenerateProviderCommand {
                commands.append(argument)
                currentArgKey = nil
            } else if argument == GenerateJsonCommand {
                commands.append(argument)
                currentArgKey = nil
            }
        }
        return (commands, parsedArgs)
    }

    private func validateArguments(commands: [String], parsedArgs: [String: String]) throws {
        guard let target = parsedArgs[TargetArgumentKey] else {
            throw ArgumentError.missingTarget
        }

        if target.isEmpty {
            throw ArgumentError.missingTarget
        }

        guard let directoryPath = parsedArgs[DirectoryArgumentKey] else {
            throw ArgumentError.missingDirectory
        }

        let directoryURL = URL(fileURLWithPath: directoryPath)
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            throw ArgumentError.invalidDirectory(directoryPath)
        }

        let validArgs = Set([TargetArgumentKey, DirectoryArgumentKey])

        let extraArgs = parsedArgs.keys.filter { !validArgs.contains($0) }

        if !extraArgs.isEmpty {
            throw ArgumentError.extraArguments(extraArgs)
        }
    }
}
