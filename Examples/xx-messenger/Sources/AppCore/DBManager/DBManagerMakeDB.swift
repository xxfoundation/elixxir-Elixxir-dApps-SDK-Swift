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
    url: URL,
    setDB: @escaping (Database) -> Void
  ) -> DBManagerMakeDB {
    DBManagerMakeDB {
      try? FileManager.default
        .createDirectory(at: url, withIntermediateDirectories: true)

      let dbFilePath = url
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
