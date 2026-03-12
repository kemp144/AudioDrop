import AVFoundation
import AppKit
import Darwin
import Foundation
import OSLog
import UniformTypeIdentifiers

private let logger = Logger(subsystem: "com.kemp144.sonicdroplet", category: "AudioFileWriter")

enum FileQuarantineManager {
    static let quarantineAttributeName = "com.apple.quarantine"

    static func clearIfPresent(at url: URL) {
        let removalStatus = url.withUnsafeFileSystemRepresentation { fileSystemPath -> Int32 in
            guard let fileSystemPath else {
                errno = EINVAL
                return -1
            }

            return removexattr(fileSystemPath, quarantineAttributeName, 0)
        }

        guard removalStatus != 0 else {
            return
        }

        let errorCode = errno
        guard errorCode != ENOATTR else {
            return
        }

        let posixCode = POSIXErrorCode(rawValue: errorCode)
        let description = posixCode.map { "\($0)" } ?? "errno \(errorCode)"
        logger.error(
            "Failed to clear quarantine attribute from \(url.path, privacy: .public): \(description, privacy: .public)"
        )
    }
}

final class AudioFileWriter: @unchecked Sendable {
    private let format: AudioFormat
    private let captureURL: URL
    private let convertedURL: URL?

    private var audioFile: AVAudioFile?
    private var hasReceivedAudio = false
    private let writeLock = NSLock()

    init(format: AudioFormat) throws {
        self.format = format

        let tempDir = FileManager.default.temporaryDirectory
        let baseFilename = "SonicDroplet_\(Self.timestampString())"

        switch format {
        case .wav:
            self.captureURL = tempDir.appendingPathComponent("\(baseFilename).wav")
            self.convertedURL = nil
        case .m4a:
            self.captureURL = tempDir.appendingPathComponent("\(baseFilename).caf")
            self.convertedURL = tempDir.appendingPathComponent("\(baseFilename).m4a")
        }

        try? FileManager.default.removeItem(at: captureURL)
        if let convertedURL {
            try? FileManager.default.removeItem(at: convertedURL)
        }

        logger.info("AudioFileWriter initialized for \(self.format.displayName) at \(self.captureURL.path)")
    }

    func appendBuffer(_ audioBuffer: AVAudioPCMBuffer) {
        writeLock.lock()
        defer { writeLock.unlock() }

        do {
            if audioFile == nil {
                try setupPCMWriter(from: audioBuffer.format)
            }

            guard let audioFile else { return }
            try audioFile.write(from: audioBuffer)
            hasReceivedAudio = true
        } catch {
            logger.error("PCM write error: \(error.localizedDescription)")
        }
    }

    private func setupPCMWriter(from format: AVAudioFormat) throws {
        audioFile = try AVAudioFile(
            forWriting: captureURL,
            settings: format.settings,
            commonFormat: format.commonFormat,
            interleaved: format.isInterleaved
        )
    }

    func finalize() async throws -> URL {
        closeCaptureFile()

        guard hasReceivedAudio else {
            throw AudioFileWriterError.noAudioWritten
        }

        let outputURL: URL
        switch format {
        case .wav:
            outputURL = captureURL
        case .m4a:
            outputURL = try await transcodeToM4A()
        }

        // Generated recordings should open like normal user documents.
        FileQuarantineManager.clearIfPresent(at: outputURL)
        return outputURL
    }

    private func transcodeToM4A() async throws -> URL {
        guard let convertedURL else {
            throw AudioFileWriterError.writerNotInitialized
        }

        try? FileManager.default.removeItem(at: convertedURL)

        let asset = AVURLAsset(url: captureURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw AudioFileWriterError.exportUnavailable
        }

        exportSession.shouldOptimizeForNetworkUse = false
        do {
            try await exportSession.export(to: convertedURL, as: .m4a)
        } catch is CancellationError {
            throw AudioFileWriterError.exportCancelled
        } catch {
            throw AudioFileWriterError.exportFailed
        }

        return convertedURL
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: captureURL)

        if let convertedURL {
            try? FileManager.default.removeItem(at: convertedURL)
        }
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }

    private func closeCaptureFile() {
        writeLock.lock()
        audioFile = nil
        writeLock.unlock()
    }
}

// MARK: - Errors

enum AudioFileWriterError: LocalizedError {
    case writerNotInitialized
    case invalidAudioFormat
    case noAudioWritten
    case exportUnavailable
    case exportFailed
    case exportCancelled

    var errorDescription: String? {
        switch self {
        case .writerNotInitialized:
            return String(localized: "error.writerNotInitialized", defaultValue: "Audio writer was not initialized")
        case .invalidAudioFormat:
            return String(localized: "error.invalidFormat", defaultValue: "Invalid audio format received")
        case .noAudioWritten:
            return String(localized: "error.noAudioWritten", defaultValue: "No audio was captured during the recording")
        case .exportUnavailable:
            return String(localized: "error.exportUnavailable", defaultValue: "SonicDroplet could not prepare the final audio file")
        case .exportFailed:
            return String(localized: "error.exportFailed", defaultValue: "SonicDroplet could not finish the recording file")
        case .exportCancelled:
            return String(localized: "error.exportCancelled", defaultValue: "The recording export was cancelled")
        }
    }
}

@MainActor
final class FileExportService {
    func exportRecording(tempURL: URL, format: AudioFormat) async throws -> URL? {
        let panel = NSSavePanel()
        panel.title = String(localized: "save.title", defaultValue: "Save Recording")
        panel.nameFieldStringValue = tempURL.lastPathComponent
        panel.allowedContentTypes = [format.contentType]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false

        let response: NSApplication.ModalResponse
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            response = await panel.beginSheetModal(for: window)
        } else {
            response = panel.runModal()
        }

        guard response == .OK, let destinationURL = panel.url else {
            return nil
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        FileQuarantineManager.clearIfPresent(at: tempURL)
        try FileManager.default.copyItem(at: tempURL, to: destinationURL)
        FileQuarantineManager.clearIfPresent(at: destinationURL)
        return destinationURL
    }
}
