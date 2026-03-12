import AVFoundation
import Combine
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.kemp144.sonicdroplet", category: "RecordingViewModel")

@MainActor
final class RecordingViewModel: ObservableObject {
    // MARK: - Published State

    @Published var recordingState: RecordingState = .idle
    @Published var audioFormat: AudioFormat = .m4a
    @Published var elapsedTime: TimeInterval = 0

    // MARK: - Services

    private let captureService = AudioCaptureService()
    private let fileExportService = FileExportService()
    // nonisolated(unsafe) because AudioFileWriter.appendBuffer is internally synchronized with NSLock
    // and is called from the audio capture queue
    nonisolated(unsafe) private var fileWriter: AudioFileWriter?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?

    // MARK: - Init

    init() {
        captureService.delegate = self
    }

    // MARK: - Recording Control

    func startRecording() async {
        guard recordingState.canStartRecording else { return }

        recordingState = .preparingToRecord

        do {
            // Initialize file writer
            fileWriter = try AudioFileWriter(format: audioFormat)
            try await captureService.startSystemAudioCapture()

            recordingState = .recording
            startTimer()

            logger.info("Recording started")
        } catch {
            logger.error("Failed to start recording: \(error.localizedDescription)")
            presentCaptureError(error)
            fileWriter?.cleanup()
            fileWriter = nil
        }
    }

    func stopRecording() async {
        guard recordingState.canStopRecording else { return }

        recordingState = .stopping
        stopTimer()

        do {
            try await captureService.stopCapture()

            guard let writer = fileWriter else {
                recordingState = .error(String(localized: "error.noWriter", defaultValue: "Recording failed — no audio was written"))
                return
            }

            recordingState = .saving
            let tempURL = try await writer.finalize()

            if let savedURL = try await fileExportService.exportRecording(tempURL: tempURL, format: audioFormat) {
                recordingState = .saved(savedURL)
                logger.info("Recording saved to \(savedURL.path)")
            } else {
                recordingState = .idle
                logger.info("Save cancelled by user")
            }

            writer.cleanup()
            fileWriter = nil
        } catch {
            logger.error("Failed to stop recording: \(error.localizedDescription)")
            presentCaptureError(error)
            fileWriter?.cleanup()
            fileWriter = nil
        }
    }

    // MARK: - Timer

    private func startTimer() {
        elapsedTime = 0
        recordingStartTime = Date()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStartTime = nil
    }

    private func presentCaptureError(_ error: Error) {
        let message = error.localizedDescription
        let lowercased = message.localizedLowercase

        if lowercased.contains("permission") || lowercased.contains("not permitted") || lowercased.contains("!hog") {
            recordingState = .error(
                String(
                    localized: "error.audioPermissionDenied",
                    defaultValue: "Audio recording permission is required. Allow SonicDroplet in System Settings and try again."
                )
            )
            return
        }

        recordingState = .error(message)
    }

    // MARK: - Formatted Time

    var formattedElapsedTime: String {
        let totalSeconds = Int(elapsedTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - AudioCaptureDelegate

extension RecordingViewModel: AudioCaptureDelegate {
    nonisolated func audioCaptureDidReceiveBuffer(_ audioBuffer: AVAudioPCMBuffer) {
        fileWriter?.appendBuffer(audioBuffer)
    }

    nonisolated func audioCaptureDidFail(with error: Error) {
        Task { @MainActor in
            logger.error("Capture failed: \(error.localizedDescription)")
            self.stopTimer()
            self.presentCaptureError(error)
            self.fileWriter?.cleanup()
            self.fileWriter = nil
        }
    }
}
