import XCTest

@testable import Tower_iOS

final class UserTests: XCTestCase {

    func testUserDecodesTowerApiFields() throws {
        let data = #"{"username":"tower-user","communicationUserId":"8:acs:123"}"#.data(using: .utf8)!

        let user = try JSONDecoder.shared.decode(User.self, from: data)

        XCTAssertEqual(user.username, "tower-user")
        XCTAssertEqual(user.communicationUserId, "8:acs:123")
    }

}
