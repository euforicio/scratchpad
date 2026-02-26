import XCTest
@testable import ScratchpadCore

final class EditorThemeTests: XCTestCase {

    // MARK: - Theme properties

    func testDarkThemeIsDark() {
        XCTAssertTrue(EditorTheme.dark.isDark)
    }

    func testLightThemeIsNotDark() {
        XCTAssertFalse(EditorTheme.light.isDark)
    }

    func testDarkInsertionPointColor() {
        XCTAssertEqual(EditorTheme.dark.insertionPointColor, .white)
    }

    func testLightInsertionPointColor() {
        XCTAssertEqual(EditorTheme.light.insertionPointColor, .black)
    }

    // MARK: - current(for:)

    func testCurrentForLight() {
        let theme = EditorTheme.current(for: "light")
        XCTAssertFalse(theme.isDark)
    }

    func testCurrentForDark() {
        let theme = EditorTheme.current(for: "dark")
        XCTAssertTrue(theme.isDark)
    }

    func testCurrentForSystemIsSafe() {
        XCTAssertNoThrow(
            _ = EditorTheme.current(for: "system")
        )
    }
}
