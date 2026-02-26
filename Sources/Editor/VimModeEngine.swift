import AppKit
import Foundation
import libvim

struct VimModeEngineState {
    let text: String
    let cursorOffset: Int
}

@MainActor
private struct CommandLineState {
    let prefix: Character?
    let text: String?
}

@MainActor
final class VimModeEngine {
    private static var isCommandHandlerInstalled = false
    private static weak var activeEngine: VimModeEngine?

    private static var isLibvimInitialized = false

    private let buffer: Vim.Buffer
    private var syncedHostText: String = ""
    private let commandHandler: ((String, Bool) -> Bool)?

    init(initialText: String, onCommand: ((String, Bool) -> Bool)? = nil) {
        commandHandler = onCommand
        if !Self.isLibvimInitialized {
            vimInit()
            Self.isLibvimInitialized = true
        }
        Self.installCommandHandlerIfNeeded()
        buffer = vimBufferOpen("", 1, 0)
        syncHostText(initialText)
    }

    func activateCommandHandler() {
        Self.activeEngine = self
    }

    func syncHostText(_ text: String) {
        if text == syncedHostText {
            return
        }
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.components(separatedBy: "\n")
        let lineCount = vimBufferGetLineCount(buffer)
        if lineCount > 0 {
            vimBufferSetLines(buffer, 0, lineCount, lines)
        } else {
            vimBufferSetLines(buffer, 0, 0, lines)
        }
        syncedHostText = normalized
    }

    func processEvent(_ event: NSEvent) -> Bool {
        activateCommandHandler()
        let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if mods.contains(.command) {
            return false
        }

        guard event.type == .keyDown else {
            return false
        }

        guard let keyString = mapEventToVimInput(event: event, modifiers: mods) else {
            return false
        }

        if isTermKey(keyString) {
            vimKey(keyString)
        } else {
            vimInput(keyString)
        }
        return true
    }

    private static func installCommandHandlerIfNeeded() {
        guard !Self.isCommandHandlerInstalled else {
            return
        }
        Self.isCommandHandlerInstalled = true
        vimSetCustomCommandHandler { exCommand in
            guard let activeEngine = Self.activeEngine else {
                return false
            }
            return activeEngine.commandHandler?(exCommand.command, exCommand.forceIt) ?? false
        }
    }

    func currentState() -> VimModeEngineState {
        let text = currentText()
        syncedHostText = text
        let line = Int(vimCursorGetLine())
        let column = Int(vimCursorGetColumn())
        return VimModeEngineState(text: text, cursorOffset: cursorOffset(forLine: line, column: column, in: text))
    }

    func currentCommandLineText() -> String? {
        let mode = vimGetMode()
        guard mode.contains(.cmdLine) else { return nil }

        let state = commandLineState()
        let commandType = state.prefix
        guard let commandType, commandType != "\0" else { return nil }

        let text = state.text ?? ""
        return "\(commandType)\(text)"
    }

    private func currentText() -> String {
        let lineCount = vimBufferGetLineCount(buffer)
        guard lineCount > 0 else { return "" }
        var lines = [String]()
        lines.reserveCapacity(lineCount)
        for index in 1...lineCount {
            lines.append(vimBufferGetLine(buffer, index))
        }
        return lines.joined(separator: "\n")
    }

    private func commandLineState() -> CommandLineState {
        let text = vimCommandLineGetText()
        let prefix = vimCommandLineGetType()
        return CommandLineState(prefix: prefix, text: text)
    }

    private func mapEventToVimInput(event: NSEvent, modifiers: NSEvent.ModifierFlags) -> String? {
        switch event.keyCode {
        case 53:
            return "<Esc>"
        case 36:
            return "<CR>"
        case 48:
            return "<Tab>"
        case 51:
            return "<BS>"
        case 117:
            return "<Del>"
        case 123:
            return "<Left>"
        case 124:
            return "<Right>"
        case 125:
            return "<Down>"
        case 126:
            return "<Up>"
        case 116:
            return "<PageUp>"
        case 121:
            return "<PageDown>"
        case 115:
            return "<Home>"
        case 119:
            return "<End>"
        default:
            break
        }

        if modifiers.contains(.control), let key = event.charactersIgnoringModifiers, let scalar = key.unicodeScalars.first {
            let value = String(scalar)
            return "<C-\(value)>"
        }

        if let text = event.characters, !text.isEmpty {
            return text
        }

        return nil
    }

    private func isTermKey(_ key: String) -> Bool {
        return key.count > 2 && key.first == "<" && key.last == ">"
    }

    private func cursorOffset(forLine line: Int, column: Int, in text: String) -> Int {
        let safeLine = max(1, line)
        let nsText = text as NSString
        guard nsText.length > 0 else { return 0 }

        var lineStart = 0
        var currentLine = 1
        while currentLine < safeLine && lineStart < nsText.length {
            let range = nsText.lineRange(for: NSRange(location: lineStart, length: 0))
            if range.length == 0 {
                break
            }
            lineStart = min(range.location + range.length, nsText.length)
            if lineStart >= nsText.length {
                break
            }
            currentLine += 1
        }

        let lineRange = nsText.lineRange(for: NSRange(location: min(lineStart, nsText.length), length: 0))
        guard lineRange.location <= nsText.length else { return nsText.length }

        let hasTrailingNewline = lineRange.length > 0 && lineRange.location + lineRange.length - 1 < nsText.length
            && nsText.character(at: lineRange.location + lineRange.length - 1) == 10
        let maxColumn = max(0, lineRange.length - (hasTrailingNewline ? 1 : 0))
        let clampedColumn = max(0, min(column, maxColumn))
        return min(lineRange.location + clampedColumn, nsText.length)
    }
}
