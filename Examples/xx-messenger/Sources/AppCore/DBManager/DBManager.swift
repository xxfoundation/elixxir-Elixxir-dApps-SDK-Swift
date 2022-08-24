import XXModels

public struct DBManager {
  public var hasDB: DBManagerHasDB
  public var makeDB: DBManagerMakeDB
  public var getDB: DBManagerGetDB
}

extension DBManager {
  public static func live() -> DBManager {
    class Container {
      var db: Database?
    }

    let container = Container()

    return DBManager(
      hasDB: .init { container.db != nil },
      makeDB: .live(setDB: { container.db = $0 }),
      getDB: .live(getDB: { container.db })
    )
  }
}

extension DBManager {
  public static let unimplemented = DBManager(
    hasDB: .unimplemented,
    makeDB: .unimplemented,
    getDB: .unimplemented
  )
}
