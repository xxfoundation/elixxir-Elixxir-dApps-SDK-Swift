import XXModels

public struct DBManager {
  public var hasDB: DBManagerHasDB
  public var makeDB: DBManagerMakeDB
  public var getDB: DBManagerGetDB
  public var removeDB: DBManagerRemoveDB
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
      getDB: .live(getDB: { container.db }),
      removeDB: .live(getDB: { container.db }, unsetDB: { container.db = nil })
    )
  }
}

extension DBManager {
  public static let unimplemented = DBManager(
    hasDB: .unimplemented,
    makeDB: .unimplemented,
    getDB: .unimplemented,
    removeDB: .unimplemented
  )
}
