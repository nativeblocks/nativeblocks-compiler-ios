import Foundation

enum ArgumentError: Error, CustomStringConvertible {
    case missingTarget
    case missingDirectory
    case missingCommand
    case invalidDirectory(String)
    case extraArguments([String])

    var description: String {
        switch self {
        case .missingTarget:
            return "Error: --target argument is missing."
        case .missingDirectory:
            return "Error: --directory argument is missing."
        case .missingCommand:
            return "Error: please use commands like: 'generate-provider', 'generate-json'"
        case .invalidDirectory(let path):
            return "Error: The directory \(path) does not exist."
        case .extraArguments(let extraArgs):
            return "Error: Extra arguments provided: \(extraArgs.joined(separator: ", "))"
        }
    }
}
