import XCTest

@testable import Tower_iOS

final class JSONCodingTests: XCTestCase {

    func testSharedJSONEncoderDoesNotEscapeSlashes() throws {
        struct Payload: Encodable {
            let url: String
        }

        let data = try JSONEncoder.shared.encode(Payload(url: "https://example.com/tower/path"))
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.contains("https://example.com/tower/path"))
        XCTAssertFalse(json.contains(#"\/"#))
    }

}
