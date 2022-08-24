import Foundation
import XCTestDynamicOverlay
import XXDatabase
import XXModels

public struct DBManagerMakeDB {
  public var run: () throws -> Void

  public func callAsFunction() throws -> Void {
    try run()
  }
}

extension DBManagerMakeDB {
  public static func live(
    setDB: @escaping (Database) -> Void
  ) -> DBManagerMakeDB {
    DBManagerMakeDB {
      let dbDirectoryURL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("database")

      try? FileManager.default
        .createDirectory(at: dbDirectoryURL, withIntermediateDirectories: true)

      let dbFilePath = dbDirectoryURL
        .appendingPathComponent("db")
        .appendingPathExtension("sqlite")
        .path

      setDB(try Database.onDisk(path: dbFilePath))
    }
  }
}

extension DBManagerMakeDB {
  public static let unimplemented = DBManagerMakeDB(
    run: XCTUnimplemented("\(Self.self)")
  )
}
