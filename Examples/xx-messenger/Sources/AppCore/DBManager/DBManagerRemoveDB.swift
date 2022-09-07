import Foundation
import XCTestDynamicOverlay
import XXDatabase
import XXModels

public struct DBManagerRemoveDB {
  public var run: () throws -> Void

  public func callAsFunction() throws -> Void {
    try run()
  }
}

extension DBManagerRemoveDB {
  public static func live(
    getDB: @escaping () -> Database?,
    unsetDB: @escaping () -> Void
  ) -> DBManagerRemoveDB {
    DBManagerRemoveDB {
      try getDB()?.drop()
      unsetDB()
    }
  }
}

extension DBManagerRemoveDB {
  public static let unimplemented = DBManagerRemoveDB(
    run: XCTUnimplemented("\(Self.self)")
  )
}
