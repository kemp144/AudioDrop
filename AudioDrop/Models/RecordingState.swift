import Foundation

enum RecordingState: Equatable {
    case idle
    case preparingToRecord
    case recording
    case stopping
    case saving
    case saved(URL)
    case error(String)

    var isRecording: Bool {
        if case .recording = self { return true }
        return false
    }

    var canStartRecording: Bool {
        switch self {
        case .idle, .saved, .error:
            return true
        default:
            return false
        }
    }

    var canStopRecording: Bool {
        if case .recording = self { return true }
        return false
    }

    var statusText: String {
        switch self {
        case .idle:
            return String(localized: "status.ready", defaultValue: "Ready to record")
        case .preparingToRecord:
            return String(localized: "status.preparing", defaultValue: "Preparing…")
        case .recording:
            return String(localized: "status.recording", defaultValue: "Recording…")
        case .stopping:
            return String(localized: "status.stopping", defaultValue: "Stopping…")
        case .saving:
            return String(localized: "status.saving", defaultValue: "Saving…")
        case .saved:
            return String(localized: "status.saved", defaultValue: "Saved successfully")
        case .error(let message):
            return message
        }
    }

    static func == (lhs: RecordingState, rhs: RecordingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.preparingToRecord, .preparingToRecord),
             (.recording, .recording),
             (.stopping, .stopping),
             (.saving, .saving):
            return true
        case (.saved(let a), .saved(let b)):
            return a == b
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
