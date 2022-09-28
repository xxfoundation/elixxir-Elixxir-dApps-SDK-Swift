import Foundation
import XCTestDynamicOverlay
import XXClient

public struct BackupCallbacksRegistry {
  public var register: (UpdateBackupFunc) -> Cancellable
  public var registered: () -> UpdateBackupFunc
}

extension BackupCallbacksRegistry {
  public static func live() -> BackupCallbacksRegistry {
    class Registry {
      var callbacks: [UUID: UpdateBackupFunc] = [:]
    }
    let registry = Registry()
    return BackupCallbacksRegistry(
      register: { callback in
        let id = UUID()
        registry.callbacks[id] = callback
        return Cancellable { registry.callbacks[id] = nil }
      },
      registered: {
        UpdateBackupFunc { data in
          registry.callbacks.values.forEach { $0.handle(data) }
        }
      }
    )
  }
}

extension BackupCallbacksRegistry {
  public static let unimplemented = BackupCallbacksRegistry(
    register: XCTUnimplemented("\(Self.self).register", placeholder: Cancellable {}),
    registered: XCTUnimplemented("\(Self.self).registered", placeholder: UpdateBackupFunc { _ in })
  )
}
