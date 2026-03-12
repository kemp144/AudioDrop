import Darwin
import Foundation
import XCTest
@testable import SonicDroplet

final class FileQuarantineManagerTests: XCTestCase {
    func testClearIfPresentRemovesQuarantineAttribute() throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        try Data("test".utf8).write(to: tempURL)
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }

        try setQuarantineAttribute(on: tempURL)
        XCTAssertTrue(hasQuarantineAttribute(on: tempURL))

        FileQuarantineManager.clearIfPresent(at: tempURL)

        XCTAssertFalse(hasQuarantineAttribute(on: tempURL))
    }

    private func setQuarantineAttribute(on url: URL) throws {
        let value = Array("0081;65f04f5a;SonicDroplet;".utf8)
        let result = try withFileSystemPath(for: url) { fileSystemPath in
            value.withUnsafeBytes { bytes in
                setxattr(
                    fileSystemPath,
                    FileQuarantineManager.quarantineAttributeName,
                    bytes.baseAddress,
                    bytes.count,
                    0,
                    0
                )
            }
        }

        guard result == 0 else {
            throw posixError(errno)
        }
    }

    private func hasQuarantineAttribute(on url: URL) -> Bool {
        let result = (try? withFileSystemPath(for: url) { fileSystemPath in
            getxattr(
                fileSystemPath,
                FileQuarantineManager.quarantineAttributeName,
                nil,
                0,
                0,
                0
            )
        }) ?? -1

        return result >= 0
    }

    private func withFileSystemPath<T>(
        for url: URL,
        _ operation: (UnsafePointer<CChar>) throws -> T
    ) throws -> T {
        try url.withUnsafeFileSystemRepresentation { fileSystemPath in
            guard let fileSystemPath else {
                throw POSIXError(.EINVAL)
            }

            return try operation(fileSystemPath)
        }
    }

    private func posixError(_ code: Int32) -> POSIXError {
        let posixCode = POSIXErrorCode(rawValue: code) ?? .EIO
        return POSIXError(posixCode)
    }
}
