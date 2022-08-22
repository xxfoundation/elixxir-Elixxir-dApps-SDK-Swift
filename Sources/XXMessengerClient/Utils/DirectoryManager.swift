import Foundation
import XCTestDynamicOverlay

public struct DirectoryManager {
  public var isEmpty: (String) -> Bool
  public var remove: (String) throws -> Void
  public var create: (String) throws -> Void
}

extension DirectoryManager {
  public static func live(
    fileManager: FileManager = .default
  ) -> DirectoryManager {
    DirectoryManager(
      isEmpty: { path in
        let contents = try? fileManager.contentsOfDirectory(atPath: path)
        return contents?.isEmpty ?? true
      },
      remove: { path in
        if fileManager.fileExists(atPath: path) {
          try fileManager.removeItem(atPath: path)
        }
      },
      create: { path in
        try fileManager.createDirectory(
          atPath: path,
          withIntermediateDirectories: true
        )
      }
    )
  }
}

extension DirectoryManager {
  public static let unimplemented = DirectoryManager(
    isEmpty: XCTUnimplemented("\(Self.self).isDirectoryEmpty"),
    remove: XCTUnimplemented("\(Self.self).removeDirectory"),
    create: XCTUnimplemented("\(Self.self).createDirectory")
  )
}
