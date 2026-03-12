import Foundation
import AppKit
import ScreenCaptureKit

struct RecordableApp: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?
    let scApplication: SCRunningApplication

    init(from app: SCRunningApplication) {
        self.id = "\(app.processID)"
        self.name = app.applicationName
        self.bundleIdentifier = app.bundleIdentifier
        self.scApplication = app

        if let bundleURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleIdentifier) {
            self.icon = NSWorkspace.shared.icon(forFile: bundleURL.path)
        } else {
            self.icon = nil
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RecordableApp, rhs: RecordableApp) -> Bool {
        lhs.id == rhs.id
    }
}
