import Cocoa

class DotRender {
    public enum Format: String, Hashable {
        /// JPEG
        case jpg

        /// JPEG
        case jpeg
        
        /// Portable Network Graphics format
        case png

        /// Scalable Vector Graphics
        case svg

    }
    
    fileprivate static func which(_ command: String) throws -> URL {
        let task = Process()
        let url = URL(fileURLWithPath: "/usr/bin/which")
        if #available(OSX 10.13, *) {
            task.executableURL = url
        } else {
            task.launchPath = url.path
        }

        task.arguments = [command.trimmingCharacters(in: .whitespacesAndNewlines)]

        let pipe = Pipe()
        task.standardOutput = pipe
        if #available(OSX 10.13, *) {
            try task.run()
        } else {
            task.launch()
        }

        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        return URL(fileURLWithPath: string)
    }

    public static func render(encoded: String, to format: DotRender.Format) throws -> Data {
        
        let url = try which("dot")
        let task = Process()
        if #available(OSX 10.13, *) {
            task.executableURL = url
        } else {
            task.launchPath = url.path
        }

        task.arguments = ["-T", format.rawValue]

        let inputPipe = Pipe()
        inputPipe.fileHandleForWriting.writeabilityHandler = { fileHandle in
            fileHandle.write(encoded.data(using: .utf8)!)
            inputPipe.fileHandleForWriting.closeFile()
        }
        task.standardInput = inputPipe

        var data = Data()

        let outputPipe = Pipe()
        defer { outputPipe.fileHandleForReading.closeFile() }
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            data.append(fileHandle.availableData)
        }
        task.standardOutput = outputPipe

        if #available(OSX 10.13, *) {
            try task.run()
        } else {
            task.launch()
        }

        task.waitUntilExit()

        return data
    }
}

extension DotRender {
    static func createNodeCode(idx: Int) -> String {
        return "    node\(idx)"
    }
    
    static func createNodeLabel(_ label: String) -> String {
        return "[label=\"\(label)\"]"
    }
    
    static func createEdge(from: String, to: String) -> String {
        return "\(from) -> \(to)\n"
    }
    
    // 固定样式
    static func render(node: String, edge: String) -> String {
        let prefix = "digraph R {\n  rankdir=LB\n    node [style=rounded, shape=box, fontsize=11, fixedsize=false] \n"
        let suffix = "}"
        let dot = prefix + node + edge + suffix
        return dot
    }
}
