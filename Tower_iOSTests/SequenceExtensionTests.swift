import XCTest

@testable import Tower_iOS

final class SequenceExtensionTests: XCTestCase {

    func testCompactedRemovesNilValuesAndPreservesOrder() {
        let values: [Int?] = [1, nil, 2, nil, 3]

        XCTAssertEqual(values.compacted(), [1, 2, 3])
    }

}
