import Bindings

public struct Backup {
  public var isRunning: BackupIsRunning
  public var addJSON: BackupAddJSON
  public var stop: BackupStop
}

extension Backup {
  public static func live(_ bindingsBackup: BindingsBackup) -> Backup {
    Backup(
      isRunning: .live(bindingsBackup),
      addJSON: .live(bindingsBackup),
      stop: .live(bindingsBackup)
    )
  }
}

extension Backup {
  public static let unimplemented = Backup(
    isRunning: .unimplemented,
    addJSON: .unimplemented,
    stop: .unimplemented
  )
}
