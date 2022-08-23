import Foundation
import XCTestDynamicOverlay

public struct MessengerFileManager {
  public var isDirectoryEmpty: (String) -> Bool
  public var removeDirectory: (String) throws -> Void
  public var createDirectory: (String) throws -> Void
}

extension MessengerFileManager {
  public static func live(
    fileManager: FileManager = .default
  ) -> MessengerFileManager {
    MessengerFileManager(
      isDirectoryEmpty: { path in
        let contents = try? fileManager.contentsOfDirectory(atPath: path)
        return contents?.isEmpty ?? true
      },
      removeDirectory: { path in
        if fileManager.fileExists(atPath: path) {
          try fileManager.removeItem(atPath: path)
        }
      },
      createDirectory: { path in
        try fileManager.createDirectory(
          atPath: path,
          withIntermediateDirectories: true
        )
      }
    )
  }
}

extension MessengerFileManager {
  public static let unimplemented = MessengerFileManager(
    isDirectoryEmpty: XCTUnimplemented("\(Self.self).isDirectoryEmpty", placeholder: false),
    removeDirectory: XCTUnimplemented("\(Self.self).removeDirectory"),
    createDirectory: XCTUnimplemented("\(Self.self).createDirectory")
  )
}
