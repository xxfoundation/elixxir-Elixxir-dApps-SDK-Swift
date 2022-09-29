import Foundation
import XCTestDynamicOverlay
import XXClient

public struct BackupStorage {
  public struct Backup: Equatable {
    public init(
      date: Date,
      data: Data
    ) {
      self.date = date
      self.data = data
    }

    public var date: Date
    public var data: Data
  }

  public typealias Observer = (Backup?) -> Void

  public var store: (Data) throws -> Void
  public var observe: (@escaping Observer) -> Cancellable
  public var remove: () throws -> Void
}

extension BackupStorage {
  public static func onDisk(
    now: @escaping () -> Date = Date.init,
    fileManager: MessengerFileManager = .live(),
    path: String = FileManager.default
      .urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first!
      .appendingPathComponent("backup.xxm")
      .path
  ) -> BackupStorage {
    var observers: [UUID: Observer] = [:]
    var backup: Backup?
    func notifyObservers() {
      observers.values.forEach { $0(backup) }
    }
    if let fileData = try? fileManager.loadFile(path),
       let fileDate = try? fileManager.modifiedTime(path) {
      backup = Backup(date: fileDate, data: fileData)
    }
    return BackupStorage(
      store: { data in
        let newBackup = Backup(
          date: now(),
          data: data
        )
        backup = newBackup
        notifyObservers()
        try fileManager.saveFile(path, newBackup.data)
      },
      observe: { observer in
        let id = UUID()
        observers[id] = observer
        defer { observers[id]?(backup) }
        return Cancellable {
          observers[id] = nil
        }
      },
      remove: {
        backup = nil
        notifyObservers()
        try fileManager.removeItem(path)
      }
    )
  }
}

extension BackupStorage {
  public static let unimplemented = BackupStorage(
    store: XCTUnimplemented("\(Self.self).store"),
    observe: XCTUnimplemented("\(Self.self).observe", placeholder: Cancellable {}),
    remove: XCTUnimplemented("\(Self.self).remove")
  )
}
