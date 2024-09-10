import Foundation

print("Main: \(CommandLine.arguments)")
if CommandLine.arguments.count < 2 {
    print("Usage: NativeblocksTool <directory>")
    exit(1)
}

let provider = NativeBlocksProvider()

let directoryPath = CommandLine.arguments[1]
let directoryURL = URL(fileURLWithPath: directoryPath)

do {
    try provider.addDirectory(at: directoryURL)
    try provider.processAll()
    
} catch {
    print("Error processing Swift files: \(error)")
    exit(1)
}
