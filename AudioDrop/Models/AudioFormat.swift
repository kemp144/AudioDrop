import Foundation
import UniformTypeIdentifiers

enum AudioFormat: String, CaseIterable, Identifiable {
    case m4a
    case wav

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .m4a:
            return "M4A"
        case .wav:
            return "WAV"
        }
    }

    var fileExtension: String {
        rawValue
    }

    var utType: String {
        switch self {
        case .m4a:
            return "com.apple.m4a-audio"
        case .wav:
            return "com.microsoft.waveform-audio"
        }
    }

    var contentType: UTType {
        switch self {
        case .m4a:
            return UTType(utType) ?? .audio
        case .wav:
            return .wav
        }
    }
}
