import Foundation
import ScreenCaptureKit
import AVFoundation
import OSLog

private let logger = Logger(subsystem: "com.audiodrop.app", category: "AudioCapture")

protocol AudioCaptureDelegate: AnyObject, Sendable {
    func audioCaptureDidReceiveBuffer(_ sampleBuffer: CMSampleBuffer)
    func audioCaptureDidFail(with error: Error)
}

@MainActor
final class AudioCaptureService: NSObject, ObservableObject {
    private var stream: SCStream?
    private let audioQueue = DispatchQueue(label: "com.audiodrop.audioCapture", qos: .userInteractive)

    nonisolated(unsafe) weak var delegate: AudioCaptureDelegate?

    private(set) var isCapturing = false

    // MARK: - System Audio Capture

    func startSystemAudioCapture() async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)

        guard let display = content.displays.first else {
            throw AudioCaptureError.noDisplayFound
        }

        // Capture all audio from the display, excluding our own app
        let selfApp = content.applications.first { $0.bundleIdentifier == Bundle.main.bundleIdentifier }
        let excludedApps = selfApp.map { [$0] } ?? []

        let filter = SCContentFilter(
            display: display,
            excludingApplications: excludedApps,
            exceptingWindows: []
        )

        try await startCapture(with: filter)
    }

    // MARK: - App Audio Capture

    func startAppAudioCapture(for app: RecordableApp) async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)

        guard let display = content.displays.first else {
            throw AudioCaptureError.noDisplayFound
        }

        let filter = SCContentFilter(
            display: display,
            including: [app.scApplication],
            exceptingWindows: []
        )

        try await startCapture(with: filter)
    }

    // MARK: - Common Capture

    private func startCapture(with filter: SCContentFilter) async throws {
        let config = SCStreamConfiguration()
        config.capturesAudio = true
        config.excludesCurrentProcessAudio = true
        config.channelCount = 2
        config.sampleRate = 48000

        // Minimize video overhead — we only need audio
        config.width = 2
        config.height = 2
        config.minimumFrameInterval = CMTime(value: 1, timescale: 1)
        config.showsCursor = false

        let stream = SCStream(filter: filter, configuration: config, delegate: self)
        try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: audioQueue)

        try await stream.startCapture()
        self.stream = stream
        self.isCapturing = true

        logger.info("Audio capture started")
    }

    func stopCapture() async throws {
        guard let stream = stream else { return }

        try await stream.stopCapture()
        self.stream = nil
        self.isCapturing = false

        logger.info("Audio capture stopped")
    }

    // MARK: - App Enumeration

    func availableApps() async throws -> [RecordableApp] {
        let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)
        let ownBundleID = Bundle.main.bundleIdentifier

        return content.applications
            .filter { !$0.applicationName.isEmpty && $0.bundleIdentifier != ownBundleID }
            .map { RecordableApp(from: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

// MARK: - SCStreamOutput

extension AudioCaptureService: SCStreamOutput {
    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio else { return }
        delegate?.audioCaptureDidReceiveBuffer(sampleBuffer)
    }
}

// MARK: - SCStreamDelegate

extension AudioCaptureService: SCStreamDelegate {
    nonisolated func stream(_ stream: SCStream, didStopWithError error: Error) {
        logger.error("Stream stopped with error: \(error.localizedDescription)")
        delegate?.audioCaptureDidFail(with: error)
    }
}

// MARK: - Errors

enum AudioCaptureError: LocalizedError {
    case noDisplayFound
    case captureAlreadyRunning
    case noAudioReceived

    var errorDescription: String? {
        switch self {
        case .noDisplayFound:
            return String(localized: "error.noDisplay", defaultValue: "No display found for audio capture")
        case .captureAlreadyRunning:
            return String(localized: "error.alreadyRunning", defaultValue: "A recording is already in progress")
        case .noAudioReceived:
            return String(localized: "error.noAudio", defaultValue: "No audio was received during recording")
        }
    }
}
