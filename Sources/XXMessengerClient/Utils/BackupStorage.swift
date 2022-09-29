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

  public var store: (Data) -> Void
  public var observe: (@escaping Observer) -> Cancellable
  public var remove: () -> Void
}

extension BackupStorage {
  public static func live(
    now: @escaping () -> Date
  ) -> BackupStorage {
    var observers: [UUID: Observer] = [:]
    var backup: Backup?
    func notifyObservers() {
      observers.values.forEach { $0(backup) }
    }

    return BackupStorage(
      store: { data in
        backup = Backup(
          date: now(),
          data: data
        )
        notifyObservers()
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
