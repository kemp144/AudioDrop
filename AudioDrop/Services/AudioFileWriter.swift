import AVFoundation
import AppKit
import Foundation
import OSLog
import UniformTypeIdentifiers

private let logger = Logger(subsystem: "com.audiodrop.app", category: "AudioFileWriter")

final class AudioFileWriter {
    private let format: AudioFormat
    private let tempURL: URL

    // M4A writing
    private var assetWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?

    // WAV writing
    private var audioFile: AVAudioFile?

    private var hasReceivedAudio = false
    private let writeLock = NSLock()

    init(format: AudioFormat) throws {
        self.format = format

        let tempDir = FileManager.default.temporaryDirectory
        let filename = "AudioDrop_\(Self.timestampString()).\(format.fileExtension)"
        self.tempURL = tempDir.appendingPathComponent(filename)

        // Clean up any existing file at the temp path
        try? FileManager.default.removeItem(at: tempURL)

        switch format {
        case .m4a:
            try setupM4AWriter()
        case .wav:
            // WAV writer is initialized on first audio buffer (we need the format description)
            break
        }

        logger.info("AudioFileWriter initialized for \(format.displayName) at \(self.tempURL.path)")
    }

    // MARK: - M4A Setup

    private func setupM4AWriter() throws {
        let writer = try AVAssetWriter(outputURL: tempURL, fileType: .m4a)

        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 192_000
        ]

        let input = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        input.expectsMediaDataInRealTime = true

        writer.add(input)

        self.assetWriter = writer
        self.audioInput = input
    }

    // MARK: - WAV Setup (deferred until first buffer)

    private func setupWAVWriter(from sampleBuffer: CMSampleBuffer) throws {
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer),
              let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else {
            throw AudioFileWriterError.invalidAudioFormat
        }

        guard let avFormat = AVAudioFormat(streamDescription: asbd) else {
            throw AudioFileWriterError.invalidAudioFormat
        }

        // Create a standard PCM format for WAV output
        guard let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: avFormat.sampleRate,
            channels: avFormat.channelCount,
            interleaved: false
        ) else {
            throw AudioFileWriterError.invalidAudioFormat
        }

        let file = try AVAudioFile(forWriting: tempURL, settings: outputFormat.settings)
        self.audioFile = file
    }

    // MARK: - Writing Buffers

    func appendBuffer(_ sampleBuffer: CMSampleBuffer) {
        writeLock.lock()
        defer { writeLock.unlock() }

        switch format {
        case .m4a:
            appendM4ABuffer(sampleBuffer)
        case .wav:
            appendWAVBuffer(sampleBuffer)
        }
    }

    private func appendM4ABuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let writer = assetWriter, let input = audioInput else { return }

        if writer.status == .unknown {
            let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            writer.startWriting()
            writer.startSession(atSourceTime: startTime)
        }

        guard writer.status == .writing else {
            if let error = writer.error {
                logger.error("AssetWriter error: \(error.localizedDescription)")
            }
            return
        }

        if input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
            hasReceivedAudio = true
        }
    }

    private func appendWAVBuffer(_ sampleBuffer: CMSampleBuffer) {
        do {
            if audioFile == nil {
                try setupWAVWriter(from: sampleBuffer)
            }

            guard let audioFile = audioFile else { return }

            guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer),
                  let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc),
                  let inputFormat = AVAudioFormat(streamDescription: asbd) else {
                return
            }

            let frameCount = CMSampleBufferGetNumSamples(sampleBuffer)
            guard frameCount > 0 else { return }

            guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: AVAudioFrameCount(frameCount)) else {
                return
            }

            pcmBuffer.frameLength = AVAudioFrameCount(frameCount)

            // Copy sample buffer data into PCM buffer
            try sampleBuffer.withAudioBufferList { bufferList, _ in
                let ablPointer = bufferList.unsafePointer
                for i in 0..<Int(ablPointer.pointee.mNumberBuffers) {
                    let srcBuffer = ablPointer.pointee.mBuffers // For single buffer
                    if i == 0, let srcData = srcBuffer.mData, let dstData = pcmBuffer.audioBufferList.pointee.mBuffers.mData {
                        memcpy(dstData, srcData, Int(srcBuffer.mDataByteSize))
                    }
                }
            }

            // If formats differ, we need conversion
            if inputFormat.commonFormat == audioFile.processingFormat.commonFormat {
                try audioFile.write(from: pcmBuffer)
            } else if let converter = AVAudioConverter(from: inputFormat, to: audioFile.processingFormat) {
                let convertedBuffer = AVAudioPCMBuffer(
                    pcmFormat: audioFile.processingFormat,
                    frameCapacity: AVAudioFrameCount(frameCount)
                )!

                var error: NSError?
                converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
                    outStatus.pointee = .haveData
                    return pcmBuffer
                }

                if let error = error {
                    logger.error("Audio conversion error: \(error.localizedDescription)")
                    return
                }

                try audioFile.write(from: convertedBuffer)
            }

            hasReceivedAudio = true
        } catch {
            logger.error("WAV write error: \(error.localizedDescription)")
        }
    }

    // MARK: - Finalize

    func finalize() async throws -> URL {
        switch format {
        case .m4a:
            return try await finalizeM4A()
        case .wav:
            return try finalizeWAV()
        }
    }

    private func finalizeM4A() async throws -> URL {
        guard let writer = assetWriter else {
            throw AudioFileWriterError.writerNotInitialized
        }

        audioInput?.markAsFinished()
        await writer.finishWriting()

        if writer.status == .failed, let error = writer.error {
            throw error
        }

        guard hasReceivedAudio else {
            throw AudioFileWriterError.noAudioWritten
        }

        return tempURL
    }

    private func finalizeWAV() throws -> URL {
        writeLock.lock()
        // Closing the AVAudioFile happens automatically when the reference is released
        audioFile = nil
        writeLock.unlock()

        guard hasReceivedAudio else {
            throw AudioFileWriterError.noAudioWritten
        }

        return tempURL
    }

    // MARK: - Cleanup

    func cleanup() {
        try? FileManager.default.removeItem(at: tempURL)
    }

    // MARK: - Helpers

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }
}

// MARK: - Errors

enum AudioFileWriterError: LocalizedError {
    case writerNotInitialized
    case invalidAudioFormat
    case noAudioWritten

    var errorDescription: String? {
        switch self {
        case .writerNotInitialized:
            return String(localized: "error.writerNotInitialized", defaultValue: "Audio writer was not initialized")
        case .invalidAudioFormat:
            return String(localized: "error.invalidFormat", defaultValue: "Invalid audio format received")
        case .noAudioWritten:
            return String(localized: "error.noAudioWritten", defaultValue: "No audio was captured during the recording")
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

        let response = await panel.beginSheetModal(for: NSApp.keyWindow ?? NSApp.mainWindow ?? NSWindow())
        guard response == .OK, let destinationURL = panel.url else {
            return nil
        }

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.copyItem(at: tempURL, to: destinationURL)
        return destinationURL
    }
}
