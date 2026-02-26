import AppKit
import XCTest
@testable import ScratchpadCore

@MainActor
final class VimModeEngineTests: XCTestCase {
    private func keyEvent(
        _ characters: String,
        keyCode: UInt16 = 0,
        modifierFlags: NSEvent.ModifierFlags = []
    ) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: modifierFlags,
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: characters,
            charactersIgnoringModifiers: characters,
            isARepeat: false,
            keyCode: keyCode
        ) ?? NSEvent()
    }

    private func type(_ engine: VimModeEngine, _ keys: [NSEvent]) {
        for key in keys {
            XCTAssertTrue(engine.processEvent(key))
        }
    }

    func testVimMotionsMoveByLine() {
        let engine = VimModeEngine(initialText: "first line\nsecond line")

        type(engine, [keyEvent("j")])
        let afterDown = engine.currentState()
        let secondLineStart = (afterDown.text as NSString).range(of: "second line").location
        XCTAssertEqual(afterDown.cursorOffset, secondLineStart)

        type(engine, [keyEvent("k")])
        let afterUp = engine.currentState()
        XCTAssertEqual(afterUp.cursorOffset, 0)
    }

    func testVimSearchMovesCursorToMatch() {
        let engine = VimModeEngine(initialText: "one two\nthree two")

        type(engine, [keyEvent("/")])
        type(engine, [keyEvent("t"), keyEvent("w"), keyEvent("o")])
        type(engine, [keyEvent("\n", keyCode: 36)])

        let state = engine.currentState()
        XCTAssertEqual(state.cursorOffset, 4)
        XCTAssertEqual(state.text, "one two\nthree two")
    }

    func testVimFindReplaceAcrossLines() {
        let engine = VimModeEngine(initialText: "apple line one\napple line two")

        type(
            engine,
            [
                keyEvent(":"),
                keyEvent("%"),
                keyEvent("s"),
                keyEvent("/"),
                keyEvent("a"),
                keyEvent("p"),
                keyEvent("p"),
                keyEvent("l"),
                keyEvent("e"),
                keyEvent("/"),
                keyEvent("o"),
                keyEvent("r"),
                keyEvent("a"),
                keyEvent("n"),
                keyEvent("g"),
                keyEvent("e"),
                keyEvent("/"),
                keyEvent("g"),
                keyEvent("\n", keyCode: 36),
            ]
        )

        XCTAssertEqual(engine.currentState().text, "orange line one\norange line two")
    }

    func testVimYankAndPasteLine() {
        let engine = VimModeEngine(initialText: "alpha\nbeta\n")

        type(engine, [keyEvent("y"), keyEvent("y"), keyEvent("p")])

        XCTAssertEqual(engine.currentState().text, "alpha\nalpha\nbeta\n")
    }

    func testVimDeleteLineCommand() {
        let engine = VimModeEngine(initialText: "alpha\nbeta\n")

        type(engine, [keyEvent("j"), keyEvent("d"), keyEvent("d")])

        XCTAssertEqual(engine.currentState().text, "alpha\n")
    }

    func testVimCustomCommandHandlerHandlesCommandAndBang() {
        var capturedCommand = ""
        var capturedForce = false

        let engine = VimModeEngine(
            initialText: "",
            onCommand: { command, force in
                capturedCommand = command
                capturedForce = force
                return true
            }
        )

        type(
            engine,
            [keyEvent(":"), keyEvent("q"), keyEvent("!"), keyEvent("\n", keyCode: 36)]
        )

        XCTAssertEqual(capturedCommand, "q!")
        XCTAssertFalse(capturedForce)
    }

    func testVimCustomCommandHandlerReceivesWriteAll() {
        var capturedCommand = ""
        let engine = VimModeEngine(
            initialText: "",
            onCommand: { command, _ in
                capturedCommand = command
                return true
            }
        )

        type(engine, [keyEvent(":"), keyEvent("w"), keyEvent("a"), keyEvent("\n", keyCode: 36)])

        XCTAssertEqual(capturedCommand, "wa")
    }
}
