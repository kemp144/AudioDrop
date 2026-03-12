import AppKit
import AVFoundation
import CoreAudio
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.audiodrop.app", category: "AudioCapture")

protocol AudioCaptureDelegate: AnyObject, Sendable {
    func audioCaptureDidReceiveBuffer(_ audioBuffer: AVAudioPCMBuffer)
    func audioCaptureDidFail(with error: Error)
}

@MainActor
final class AudioCaptureService: NSObject, ObservableObject {
    private let tapSession = CoreAudioTapSession()

    weak var delegate: AudioCaptureDelegate? {
        didSet {
            tapSession.delegate = delegate
        }
    }

    private(set) var isCapturing = false

    override init() {
        super.init()
        tapSession.delegate = delegate
    }

    // MARK: - System Audio Capture

    func startSystemAudioCapture() async throws {
        guard !isCapturing else {
            throw AudioCaptureError.captureAlreadyRunning
        }

        do {
            try tapSession.startSystemCapture()
            isCapturing = true
            logger.info("System audio capture started")
        } catch {
            tapSession.stop()
            throw error
        }
    }

    // MARK: - Common Capture

    func stopCapture() async throws {
        tapSession.stop()
        isCapturing = false
        logger.info("Audio capture stopped")
    }
}

private final class CoreAudioTapSession {
    weak var delegate: AudioCaptureDelegate?

    private let audioSystem = AudioHardwareSystem.shared
    private let audioQueue = DispatchQueue(label: "com.audiodrop.audioCapture", qos: .userInitiated)

    private var tap: AudioHardwareTap?
    private var aggregateDevice: AudioHardwareAggregateDevice?
    private var ioProcID: AudioDeviceIOProcID?
    private var captureFormat: AVAudioFormat?

    func startSystemCapture() throws {
        let ownProcessID = ProcessInfo.processInfo.processIdentifier
        let excludedProcessID = try audioSystem.process(for: ownProcessID)?.id
        let excludedProcessIDs = excludedProcessID.map { [$0] } ?? []

        let tapDescription = CATapDescription(stereoGlobalTapButExcludeProcesses: excludedProcessIDs)
        try startCapture(with: tapDescription)
    }

    func stop() {
        let deviceID = aggregateDevice?.id
        let ioProcID = ioProcID

        if let deviceID, let ioProcID {
            let stopStatus = AudioDeviceStop(deviceID, ioProcID)
            if stopStatus != noErr {
                logger.error("AudioDeviceStop failed: \(Self.formatStatus(stopStatus))")
            }

            let destroyIOStatus = AudioDeviceDestroyIOProcID(deviceID, ioProcID)
            if destroyIOStatus != noErr {
                logger.error("AudioDeviceDestroyIOProcID failed: \(Self.formatStatus(destroyIOStatus))")
            }
        }

        if let aggregateDevice {
            do {
                try audioSystem.destroyAggregateDevice(aggregateDevice)
            } catch {
                logger.error("Failed to destroy aggregate device: \(error.localizedDescription)")
            }
        }

        if let tap {
            do {
                try audioSystem.destroyProcessTap(tap)
            } catch {
                logger.error("Failed to destroy process tap: \(error.localizedDescription)")
            }
        }

        self.ioProcID = nil
        self.aggregateDevice = nil
        self.tap = nil
        self.captureFormat = nil
    }

    private func startCapture(with tapDescription: CATapDescription) throws {
        tapDescription.name = "AudioDrop"
        tapDescription.isPrivate = true
        tapDescription.muteBehavior = .unmuted

        let defaultOutputDevice = try audioSystem.defaultOutputDevice
        let defaultOutputUID = try defaultOutputDevice?.uid

        guard let tap = try audioSystem.makeProcessTap(description: tapDescription) else {
            throw AudioCaptureError.failedToCreateTap
        }
        self.tap = tap

        var aggregateDescription: [String: Any] = [
            kAudioAggregateDeviceNameKey: "AudioDrop Capture",
            kAudioAggregateDeviceUIDKey: "com.audiodrop.capture.\(UUID().uuidString)",
            kAudioAggregateDeviceIsPrivateKey: true,
            kAudioAggregateDeviceTapListKey: [[
                kAudioSubTapUIDKey: try tap.uid,
                kAudioSubTapDriftCompensationKey: true
            ]],
            kAudioAggregateDeviceTapAutoStartKey: true
        ]

        if let defaultOutputUID {
            aggregateDescription[kAudioAggregateDeviceSubDeviceListKey] = [[
                kAudioSubDeviceUIDKey: defaultOutputUID
            ]]
            aggregateDescription[kAudioAggregateDeviceMainSubDeviceKey] = defaultOutputUID
        }

        guard let aggregateDevice = try audioSystem.makeAggregateDevice(description: aggregateDescription) else {
            throw AudioCaptureError.failedToCreateAggregateDevice
        }
        self.aggregateDevice = aggregateDevice

        var streamDescription = try tap.format
        guard let captureFormat = AVAudioFormat(streamDescription: &streamDescription) else {
            throw AudioCaptureError.invalidTapFormat
        }
        self.captureFormat = captureFormat

        var ioProcID: AudioDeviceIOProcID?
        let createIOStatus = AudioDeviceCreateIOProcIDWithBlock(
            &ioProcID,
            aggregateDevice.id,
            audioQueue
        ) { [weak self] _, inputData, _, _, _ in
            self?.handleCapturedAudio(inputData)
        }
        try Self.checkStatus(createIOStatus, operation: "create IO proc")

        guard let ioProcID else {
            throw AudioCaptureError.failedToCreateIOProc
        }

        self.ioProcID = ioProcID

        let startStatus = AudioDeviceStart(aggregateDevice.id, ioProcID)
        do {
            try Self.checkStatus(startStatus, operation: "start capture")
        } catch {
            stop()
            throw error
        }
    }

    private func handleCapturedAudio(_ inputData: UnsafePointer<AudioBufferList>) {
        guard let captureFormat else { return }
        guard let pcmBuffer = Self.makePCMBuffer(from: inputData, format: captureFormat) else { return }
        delegate?.audioCaptureDidReceiveBuffer(pcmBuffer)
    }

    private static func makePCMBuffer(
        from inputData: UnsafePointer<AudioBufferList>,
        format: AVAudioFormat
    ) -> AVAudioPCMBuffer? {
        let mutableBufferList = UnsafeMutablePointer(mutating: inputData)
        let audioBuffers = UnsafeMutableAudioBufferListPointer(mutableBufferList)

        guard let firstBufferWithData = audioBuffers.first(where: { $0.mDataByteSize > 0 }) else {
            return nil
        }

        let bytesPerFrame = max(format.streamDescription.pointee.mBytesPerFrame, 1)
        let frameCount = AVAudioFrameCount(firstBufferWithData.mDataByteSize / bytesPerFrame)
        guard frameCount > 0 else {
            return nil
        }

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: mutableBufferList) else {
            return nil
        }

        pcmBuffer.frameLength = frameCount
        return pcmBuffer
    }

    private static func checkStatus(_ status: OSStatus, operation: String) throws {
        guard status == noErr else {
            if status == kAudioDevicePermissionsError {
                throw AudioCaptureError.permissionDenied
            }

            throw AudioCaptureError.coreAudioFailure(
                operation: operation,
                statusDescription: formatStatus(status)
            )
        }
    }

    private static func formatStatus(_ status: OSStatus) -> String {
        let bigEndian = CFSwapInt32HostToBig(UInt32(bitPattern: status))
        let bytes = [
            UInt8((bigEndian >> 24) & 0xFF),
            UInt8((bigEndian >> 16) & 0xFF),
            UInt8((bigEndian >> 8) & 0xFF),
            UInt8(bigEndian & 0xFF)
        ]

        let printable = bytes.allSatisfy { $0 >= 32 && $0 < 127 }
        if printable, let fourCC = String(bytes: bytes, encoding: .macOSRoman) {
            return "'\(fourCC)'"
        }

        return "\(status)"
    }
}

// MARK: - Errors

enum AudioCaptureError: LocalizedError {
    case captureAlreadyRunning
    case failedToCreateTap
    case failedToCreateAggregateDevice
    case failedToCreateIOProc
    case invalidTapFormat
    case permissionDenied
    case coreAudioFailure(operation: String, statusDescription: String)

    var errorDescription: String? {
        switch self {
        case .captureAlreadyRunning:
            return String(localized: "error.alreadyRunning", defaultValue: "A recording is already in progress")
        case .failedToCreateTap:
            return String(localized: "error.failedToCreateTap", defaultValue: "AudioDrop could not start system audio capture")
        case .failedToCreateAggregateDevice:
            return String(localized: "error.failedToCreateAggregateDevice", defaultValue: "AudioDrop could not prepare the audio capture device")
        case .failedToCreateIOProc:
            return String(localized: "error.failedToCreateIOProc", defaultValue: "AudioDrop could not start reading captured audio")
        case .invalidTapFormat:
            return String(localized: "error.invalidTapFormat", defaultValue: "AudioDrop received an unsupported audio format")
        case .permissionDenied:
            return String(localized: "error.audioPermissionDenied", defaultValue: "Audio recording permission is required. Allow AudioDrop in System Settings and try again.")
        case .coreAudioFailure(let operation, let statusDescription):
            return String(
                localized: "error.coreAudioFailure",
                defaultValue: "Audio capture failed while trying to \(operation) (\(statusDescription))."
            )
        }
    }
}
