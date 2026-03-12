import XCTest
@testable import SonicDroplet

final class AudioFormatTests: XCTestCase {

    func testFileExtensions() {
        XCTAssertEqual(AudioFormat.m4a.fileExtension, "m4a")
        XCTAssertEqual(AudioFormat.wav.fileExtension, "wav")
    }

    func testDisplayNames() {
        XCTAssertEqual(AudioFormat.m4a.displayName, "M4A")
        XCTAssertEqual(AudioFormat.wav.displayName, "WAV")
    }

    func testAllCasesCount() {
        XCTAssertEqual(AudioFormat.allCases.count, 2)
    }

    func testUTTypes() {
        XCTAssertEqual(AudioFormat.m4a.utType, "com.apple.m4a-audio")
        XCTAssertEqual(AudioFormat.wav.utType, "com.microsoft.waveform-audio")
    }

    func testIdentifiable() {
        XCTAssertEqual(AudioFormat.m4a.id, "m4a")
        XCTAssertEqual(AudioFormat.wav.id, "wav")
    }
}
