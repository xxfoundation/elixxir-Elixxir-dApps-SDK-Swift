import Foundation
import XCTestDynamicOverlay

public struct MessengerFileManager {
  public var isDirectoryEmpty: (String) -> Bool
  public var removeItem: (String) throws -> Void
  public var createDirectory: (String) throws -> Void
  public var saveFile: (String, Data) throws -> Void
  public var loadFile: (String) throws -> Data?
  public var modifiedTime: (String) throws -> Date?
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
      removeItem: { path in
        if fileManager.fileExists(atPath: path) {
          try fileManager.removeItem(atPath: path)
        }
      },
      createDirectory: { path in
        try fileManager.createDirectory(
          atPath: path,
          withIntermediateDirectories: true
        )
      },
      saveFile: { path, data in
        try data.write(to: URL(fileURLWithPath: path))
      },
      loadFile: { path in
        try Data(contentsOf: URL(fileURLWithPath: path))
      },
      modifiedTime: { path in
        let attributes = try fileManager.attributesOfItem(atPath: path)
        return attributes[.modificationDate] as? Date
      }
    )
  }
}

extension MessengerFileManager {
  public static let unimplemented = MessengerFileManager(
    isDirectoryEmpty: XCTUnimplemented("\(Self.self).isDirectoryEmpty", placeholder: false),
    removeItem: XCTUnimplemented("\(Self.self).removeItem"),
    createDirectory: XCTUnimplemented("\(Self.self).createDirectory"),
    saveFile: XCTUnimplemented("\(Self.self).saveFile"),
    loadFile: XCTUnimplemented("\(Self.self).loadFile"),
    modifiedTime: XCTUnimplemented("\(Self.self).modifiedTime")
  )
}
