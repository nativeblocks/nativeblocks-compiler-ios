import Foundation

print("arguments: \(CommandLine.arguments)")
do {
    let tool = try NativeblocksToolExecutor(CommandLine.arguments)
    try tool.execute()
} catch {
    guard let errorModel = error as? ErrorModel else {
        print("NativeblocksTool \(error)")
        exit(1)
    }

    print("NativeblocksTool Error message:\(errorModel.message ?? "") type:\(errorModel.errorType ?? "")  ")
    exit(1)
}
