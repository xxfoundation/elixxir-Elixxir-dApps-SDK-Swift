import XCTestDynamicOverlay
import XXModels

public struct DBManagerGetDB {
  public enum Error: Swift.Error, Equatable {
    case missingDB
  }

  public var run: () throws -> Database

  public func callAsFunction() throws -> Database {
    try run()
  }
}

extension DBManagerGetDB {
  public static func live(
    getDB: @escaping () -> Database?
  ) -> DBManagerGetDB {
    DBManagerGetDB {
      guard let db = getDB() else {
        throw Error.missingDB
      }
      return db
    }
  }
}

extension DBManagerGetDB {
  public static let unimplemented = DBManagerGetDB(
    run: XCTUnimplemented("\(Self.self)")
  )
}
