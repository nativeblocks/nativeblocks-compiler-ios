import Foundation
import PackagePlugin

@main
struct NativeblocksPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("NativeblocksPlugin:CommandPlugin performCommand \(context.pluginWorkDirectory.string)")
//        let fileManager = FileManager.default
//
//        // Iterate through all package targets and scan for .swift files
//        for target in context.package.targets {
//            // Get the directory path as a string
//            guard let targetDirectory = try? target.directory.string else {
//                print("Error getting directory path for target \(target.name)")
//                continue
//            }
//
//            // Get all Swift files in the target directory
//            let swiftFiles: [String]
//            do {
//                swiftFiles = try getSwiftFiles(in: targetDirectory)
//            } catch {
//                print("Error finding Swift files in target: \(error)")
//                continue
//            }
//
//            // Process each Swift file
//            for file in swiftFiles {
//                print("Processing file: \(file)")
//
//                // Read the contents of the file
//                let content: String
//                do {
//                    content = try String(contentsOfFile: file, encoding: .utf8)
//                } catch {
//                    print("Error reading file \(file): \(error)")
//                    continue
//                }
//
//                // Parse the Swift file content to find annotations
//                parseSwiftFile(content: content)
//            }
//        }
    }

    // Recursively find all .swift files in the target directory
    func getSwiftFiles(in directory: String) throws -> [String] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: directory)  // Type: FileManager.DirectoryEnumerator?

        var swiftFiles: [String] = []
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".swift") {
                swiftFiles.append(directory + "/" + element)
            }
        }
        return swiftFiles
    }

    // Parse the content of a Swift file to find @NativeAction annotations
    func parseSwiftFile(content: String) {
        let lines: [Substring] = content.split(separator: "\n")

        var className: String?
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine.contains("@NativeAction") {
                // Look for the class or struct definition after the annotation
                for i in (index + 1)..<lines.count {
                    let nextLine = lines[i].trimmingCharacters(in: .whitespaces)

                    if nextLine.hasPrefix("class ") || nextLine.hasPrefix("struct ") {
                        let components = nextLine.split(separator: " ")
                        if components.count > 1 {
                            className = String(components[1])  // Extract class name
                            print("Found class annotated with @NativeAction: \(className!)")
                            generateProvider(for: className!)
                        }
                        break
                    }
                }
            }
        }
    }

    func generateProvider(for className: String) -> String {
        let providerCode = """
            class \(className)Provider {
                func provide() -> \(className) {
                    return \(className)()
                }
            }
            """
        print("Generated provider for class \(className):\n\(providerCode)")
        return providerCode
    }
}



#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension NativeblocksPlugin: XcodeCommandPlugin {

  /// 👇 This entry point is called when operating on an Xcode project.
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    print("NativeblocksPlugin:XcodeCommandPlugin performCommand  \(context.xcodeProject.displayName)")
//    let apolloPath = "\(context.pluginWorkDirectory)/../../checkouts/apollo-ios"
//    let process = Process()
//    let path = try context.tool(named: "sh").path
//    process.executableURL = URL(fileURLWithPath: path.string)
//    process.arguments = ["\(apolloPath)/scripts/download-cli.sh", context.xcodeProject.directory.string]
//    try process.run()
//    process.waitUntilExit()
  }

}
#endif
