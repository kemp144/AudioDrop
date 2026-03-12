import XCTest
@testable import AudioDrop

final class RecordingModeTests: XCTestCase {

    func testAllCasesCount() {
        XCTAssertEqual(RecordingMode.allCases.count, 2)
    }

    func testDisplayNamesNotEmpty() {
        for mode in RecordingMode.allCases {
            XCTAssertFalse(mode.displayName.isEmpty)
        }
    }

    func testDescriptionsNotEmpty() {
        for mode in RecordingMode.allCases {
            XCTAssertFalse(mode.description.isEmpty)
        }
    }

    func testIdentifiable() {
        XCTAssertEqual(RecordingMode.systemAudio.id, "systemAudio")
        XCTAssertEqual(RecordingMode.appAudio.id, "appAudio")
    }
}
