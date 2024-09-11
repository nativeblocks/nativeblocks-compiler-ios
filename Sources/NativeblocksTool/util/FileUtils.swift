import Foundation

struct FileUtils {
    static func getFiles(from directory: URL) throws -> [URL] {
        var filePaths: [URL] = []
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for url in contents {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                try  filePaths.append(contentsOf:getFiles(from: url))
            } else if url.pathExtension == "swift" {
                print(url.absoluteString)
                filePaths.append(url)
            }
        }
        return filePaths
    }
    
    static func getFilesContent(from files: [URL]) throws -> [String] {
        return files.compactMap { filePath in
            try? String(contentsOf: filePath, encoding: .utf8)
        }
    }
    
    static func getFilesContent(from directory: URL) throws -> [String] {
        let files = try getFiles(from:directory)
        return files.compactMap { filePath in
            try? String(contentsOf: filePath, encoding: .utf8)
        }
    }
}
