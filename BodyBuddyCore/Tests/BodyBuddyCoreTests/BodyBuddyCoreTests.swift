import XCTest
@testable import BodyBuddyCore

final class BodyBuddyCoreTests: XCTestCase {

    func testVersion() {
        XCTAssertEqual(BodyBuddyCore.version, "0.1.0")
    }
}
