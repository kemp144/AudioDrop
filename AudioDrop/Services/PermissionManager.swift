import AppKit
import CoreGraphics
import Foundation
import ScreenCaptureKit

enum ScreenCapturePermissionState: Equatable {
    case notDetermined
    case granted
    case denied
}

@MainActor
final class PermissionManager: ObservableObject {
    @Published private(set) var hasScreenRecordingPermission = false
    @Published private(set) var permissionState: ScreenCapturePermissionState = .notDetermined

    func checkPermission() async {
        let hasAccess = CGPreflightScreenCaptureAccess()
        hasScreenRecordingPermission = hasAccess
        permissionState = hasAccess ? .granted : .denied
    }

    func refreshPermissionStateOnLaunch() {
        let hasAccess = CGPreflightScreenCaptureAccess()
        hasScreenRecordingPermission = hasAccess
        permissionState = hasAccess ? .granted : .notDetermined
    }

    func requestPermission() {
        let granted = CGRequestScreenCaptureAccess()
        hasScreenRecordingPermission = granted
        permissionState = granted ? .granted : .denied
    }

    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}
