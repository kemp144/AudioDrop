import Foundation

enum RecordingMode: String, CaseIterable, Identifiable {
    case systemAudio
    case appAudio

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .systemAudio:
            return String(localized: "mode.systemAudio", defaultValue: "System Audio")
        case .appAudio:
            return String(localized: "mode.appAudio", defaultValue: "Selected App Audio")
        }
    }

    var description: String {
        switch self {
        case .systemAudio:
            return String(localized: "mode.systemAudio.description", defaultValue: "Record all audio playing on your Mac")
        case .appAudio:
            return String(localized: "mode.appAudio.description", defaultValue: "Record audio from one selected app")
        }
    }
}
