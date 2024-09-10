import Foundation
import PackagePlugin

@main
struct GenerateProvider: CommandPlugin {
    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) throws {
        let tool = try context.tool(named: "NativeblocksCompilerClient")
        let toolURL = URL(fileURLWithPath: tool.path.string)
        
        
        print("pluginWorkDirectory:\(context.pluginWorkDirectory)")
        print("directory:\(context.package.directory)")
        print("displayName:\(context.package.displayName)")

        let processArguments = [context.package.directory.string]

        try callNativeblocksCompilerClient(toolURL: toolURL, arguments: processArguments)
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension GenerateProvider: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "NativeblocksCompilerClient")
        let toolURL = URL(fileURLWithPath: tool.path.string)

        print("directory:\(context.xcodeProject.directory)")
        print("directory string:\(context.xcodeProject.directory.string)")
        print("pluginWorkDirectory:\(context.pluginWorkDirectory)")
        let processArguments = [context.xcodeProject.directory.string]

        try callNativeblocksCompilerClient(toolURL: toolURL, arguments: processArguments)
    }
}

#endif

func callNativeblocksCompilerClient(toolURL: URL, arguments: [String]) throws {
    let process = Process()
    process.executableURL = toolURL
    process.arguments = arguments
    
    print("callNativeblocksCompilerClient: \(arguments)")

    try process.run()
    process.waitUntilExit()

    if process.terminationStatus == 0 {
        print("Successfully ran NativeblocksCompilerClient with arguments.")
    } else {
        print("Failed to run NativeblocksCompilerClient. Exit code: \(process.terminationStatus)")
    }
}
