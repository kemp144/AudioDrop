import Foundation
import XCTest

final class LocalizationCatalogTests: XCTestCase {
    private let supportedLocales = [
        "ar", "ca", "hr", "cs", "da", "de", "el", "en", "en-AU", "en-CA", "en-GB",
        "es-ES", "es-MX", "fi", "fr", "fr-CA", "he", "hi", "hu", "id", "it", "ja",
        "ko", "ms", "nb", "nl", "pl", "pt-BR", "pt-PT", "ro", "ru", "sk", "sv",
        "th", "tr", "uk", "vi", "zh-Hans", "zh-Hant"
    ]

    private let requiredLocalizedKeys = [
        "record.subtitle",
        "Source",
        "System Audio",
        "Records the audio currently playing on your Mac.",
        "Local-only. Choose where to save after you stop recording.",
        "format.label",
        "save.summary",
        "recording.elapsed.label %@",
        "recording.start",
        "recording.start.hint",
        "recording.stop",
        "recording.stop.hint",
        "status.showInFinder",
        "status.showInFinder.hint",
        "save.title",
        "status.preparing",
        "status.ready",
        "status.recording",
        "status.saved",
        "status.saving",
        "status.stopping",
        "error.alreadyRunning",
        "error.audioPermissionDenied",
        "error.coreAudioFailure",
        "error.failedToCreateTap",
        "error.failedToCreateAggregateDevice",
        "error.failedToCreateIOProc",
        "error.invalidTapFormat",
        "error.writerNotInitialized",
        "error.invalidFormat",
        "error.noAudioWritten",
        "error.exportUnavailable",
        "error.exportFailed",
        "error.exportCancelled",
        "error.noWriter"
    ]

    func testLocalizableCatalogCoversAllShippingLocales() throws {
        let catalog = try loadCatalog(at: "SonicDroplet/Resources/Localizable.xcstrings")
        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])

        for key in requiredLocalizedKeys {
            let entry = try XCTUnwrap(strings[key] as? [String: Any], "Missing catalog entry for \(key)")
            let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any], "Missing localizations for \(key)")
            assertCoverage(for: key, localizations: localizations)
        }
    }

    func testInfoPlistCatalogCoversAllShippingLocales() throws {
        let catalog = try loadCatalog(at: "SonicDroplet/Resources/InfoPlist.xcstrings")
        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])
        let usageDescription = try XCTUnwrap(strings["NSAudioCaptureUsageDescription"] as? [String: Any])
        let localizations = try XCTUnwrap(usageDescription["localizations"] as? [String: Any])

        assertCoverage(for: "NSAudioCaptureUsageDescription", localizations: localizations)
    }

    private func assertCoverage(for key: String, localizations: [String: Any]) {
        let missing = supportedLocales.filter { localizations[$0] == nil }
        XCTAssertTrue(missing.isEmpty, "Missing locales for \(key): \(missing.joined(separator: ", "))")

        for locale in supportedLocales {
            guard
                let localeEntry = localizations[locale] as? [String: Any],
                let stringUnit = localeEntry["stringUnit"] as? [String: Any],
                let value = stringUnit["value"] as? String
            else {
                XCTFail("Invalid localization payload for \(key) / \(locale)")
                continue
            }

            XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "Empty translation for \(key) / \(locale)")
        }
    }

    private func loadCatalog(at relativePath: String) throws -> [String: Any] {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let catalogURL = repoRoot.appendingPathComponent(relativePath)
        let data = try Data(contentsOf: catalogURL)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
