import Foundation

print("arguments: \(CommandLine.arguments)")
do {
    let tool = try NativeblocksToolExecutor(CommandLine.arguments)
    try tool.execute()
} catch {
    print("NativeblocksTool \(error)")
    exit(1)
}
