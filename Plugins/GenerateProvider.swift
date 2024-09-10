import Foundation
import PackagePlugin

@main
struct GenerateProvider: CommandPlugin {
    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) throws {
        let tool = try context.tool(named: "NativeblocksTool")
        let toolURL = URL(fileURLWithPath: tool.path.string)

        var processArguments = arguments

        if processArguments.filter({ arg in
            arg == "--directory"
        }).count == 0 {
            processArguments.append(contentsOf: ["--directory", context.package.directory.string])
        }
        try callNativeblocksCompilerClient(toolURL: toolURL, arguments: processArguments)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension GenerateProvider: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "NativeblocksTool")
        let toolURL = URL(fileURLWithPath: tool.path.string)
        var processArguments = arguments

        if processArguments.filter({ arg in
            arg == "--directory"
        }).count == 0 {
            processArguments.append(contentsOf: ["--directory", context.xcodeProject.directory.string])
        }
        try callNativeblocksCompilerClient(toolURL: toolURL, arguments: processArguments)
    }
}

#endif

func callNativeblocksCompilerClient(toolURL: URL, arguments: [String]) throws {
    let process = Process()
    process.executableURL = toolURL
    process.arguments = arguments

    print("call NativeblocksTool: \(arguments)")

    try process.run()
    process.waitUntilExit()

    if process.terminationStatus == 0 {
        print("Successfully ran call NativeblocksTool with arguments.")
    } else {
        print("Failed to run call NativeblocksTool. Exit code: \(process.terminationStatus)")
    }
}
