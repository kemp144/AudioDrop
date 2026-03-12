import AppKit
import Combine
import CoreMedia
import Foundation
import OSLog
import SwiftUI

private let logger = Logger(subsystem: "com.audiodrop.app", category: "RecordingViewModel")

@MainActor
final class RecordingViewModel: ObservableObject {
    // MARK: - Published State

    @Published var recordingState: RecordingState = .idle
    @Published var recordingMode: RecordingMode = .systemAudio
    @Published var audioFormat: AudioFormat = .m4a
    @Published var selectedApp: RecordableApp?
    @Published var availableApps: [RecordableApp] = []
    @Published var elapsedTime: TimeInterval = 0
    @Published var showPermissionExplanation = false
    @Published var showAppPicker = false
    @Published var shouldPromptForPermission = false

    // MARK: - Services

    let permissionManager = PermissionManager()
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
        permissionManager.refreshPermissionStateOnLaunch()
    }

    // MARK: - Recording Control

    func startRecording() async {
        guard recordingState.canStartRecording else { return }

        guard permissionManager.hasScreenRecordingPermission else {
            shouldPromptForPermission = permissionManager.permissionState == .notDetermined
            showPermissionExplanation = true
            recordingState = .permissionRequired
            return
        }

        recordingState = .preparingToRecord

        do {
            // Initialize file writer
            fileWriter = try AudioFileWriter(format: audioFormat)

            // Start capture based on mode
            switch recordingMode {
            case .systemAudio:
                try await captureService.startSystemAudioCapture()
            case .appAudio:
                guard let app = selectedApp else {
                    recordingState = .error(String(localized: "error.noAppSelected", defaultValue: "Please select an app to record"))
                    return
                }
                try await captureService.startAppAudioCapture(for: app)
            }

            recordingState = .recording
            startTimer()

            logger.info("Recording started in \(self.recordingMode.rawValue) mode")
        } catch {
            logger.error("Failed to start recording: \(error.localizedDescription)")
            recordingState = .error(error.localizedDescription)
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
            recordingState = .error(error.localizedDescription)
            fileWriter?.cleanup()
            fileWriter = nil
        }
    }

    // MARK: - App Selection

    func refreshAvailableApps() async {
        do {
            availableApps = try await captureService.availableApps()
        } catch {
            logger.error("Failed to load apps: \(error.localizedDescription)")
            availableApps = []
        }
    }

    func selectApp(_ app: RecordableApp) {
        selectedApp = app
        showAppPicker = false
    }

    // MARK: - Permission

    func openScreenRecordingSettings() {
        permissionManager.openSystemSettings()
    }

    func recheckPermission() async {
        await permissionManager.checkPermission()
        if permissionManager.hasScreenRecordingPermission {
            shouldPromptForPermission = false
            showPermissionExplanation = false
            recordingState = .idle
        }
    }

    func requestScreenRecordingPermission() async {
        permissionManager.requestPermission()
        await permissionManager.checkPermission()

        if permissionManager.hasScreenRecordingPermission {
            shouldPromptForPermission = false
            showPermissionExplanation = false
            recordingState = .idle
        } else {
            recordingState = .permissionRequired
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
    nonisolated func audioCaptureDidReceiveBuffer(_ sampleBuffer: CMSampleBuffer) {
        // Write audio buffer to file — this happens on the audio queue
        fileWriter?.appendBuffer(sampleBuffer)
    }

    nonisolated func audioCaptureDidFail(with error: Error) {
        Task { @MainActor in
            logger.error("Capture failed: \(error.localizedDescription)")
            self.stopTimer()
            self.recordingState = .error(error.localizedDescription)
            self.fileWriter?.cleanup()
            self.fileWriter = nil
        }
    }
}
