import XCTest
@testable import AudioDrop

final class RecordingStateTests: XCTestCase {

    // MARK: - State Flags

    func testIdleCanStartRecording() {
        let state = RecordingState.idle
        XCTAssertTrue(state.canStartRecording)
        XCTAssertFalse(state.canStopRecording)
        XCTAssertFalse(state.isRecording)
    }

    func testRecordingCanStop() {
        let state = RecordingState.recording
        XCTAssertFalse(state.canStartRecording)
        XCTAssertTrue(state.canStopRecording)
        XCTAssertTrue(state.isRecording)
    }

    func testPreparingCannotStartOrStop() {
        let state = RecordingState.preparingToRecord
        XCTAssertFalse(state.canStartRecording)
        XCTAssertFalse(state.canStopRecording)
    }

    func testStoppingCannotStartOrStop() {
        let state = RecordingState.stopping
        XCTAssertFalse(state.canStartRecording)
        XCTAssertFalse(state.canStopRecording)
    }

    func testSavingCannotStartOrStop() {
        let state = RecordingState.saving
        XCTAssertFalse(state.canStartRecording)
        XCTAssertFalse(state.canStopRecording)
    }

    func testSavedCanStartRecording() {
        let url = URL(fileURLWithPath: "/tmp/test.m4a")
        let state = RecordingState.saved(url)
        XCTAssertTrue(state.canStartRecording)
        XCTAssertFalse(state.canStopRecording)
    }

    func testErrorCanStartRecording() {
        let state = RecordingState.error("Something went wrong")
        XCTAssertTrue(state.canStartRecording)
        XCTAssertFalse(state.canStopRecording)
    }

    func testPermissionRequiredCanStartRecording() {
        let state = RecordingState.permissionRequired
        XCTAssertTrue(state.canStartRecording)
        XCTAssertFalse(state.canStopRecording)
    }

    // MARK: - Equality

    func testEqualityForSimpleStates() {
        XCTAssertEqual(RecordingState.idle, RecordingState.idle)
        XCTAssertEqual(RecordingState.recording, RecordingState.recording)
        XCTAssertNotEqual(RecordingState.idle, RecordingState.recording)
    }

    func testEqualityForSaved() {
        let url1 = URL(fileURLWithPath: "/tmp/a.m4a")
        let url2 = URL(fileURLWithPath: "/tmp/b.m4a")
        XCTAssertEqual(RecordingState.saved(url1), RecordingState.saved(url1))
        XCTAssertNotEqual(RecordingState.saved(url1), RecordingState.saved(url2))
    }

    func testEqualityForError() {
        XCTAssertEqual(RecordingState.error("A"), RecordingState.error("A"))
        XCTAssertNotEqual(RecordingState.error("A"), RecordingState.error("B"))
    }

    // MARK: - Status Text

    func testStatusTextNotEmpty() {
        let states: [RecordingState] = [
            .idle, .preparingToRecord, .recording, .stopping,
            .saving, .saved(URL(fileURLWithPath: "/tmp/t.m4a")),
            .permissionRequired, .error("test error")
        ]

        for state in states {
            XCTAssertFalse(state.statusText.isEmpty, "Status text should not be empty for \(state)")
        }
    }
}
