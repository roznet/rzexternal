import XCTest
@testable import RZExternal

final class RZExternalTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RZExternal().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
