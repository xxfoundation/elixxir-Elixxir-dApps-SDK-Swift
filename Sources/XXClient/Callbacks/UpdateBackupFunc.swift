import Bindings
import XCTestDynamicOverlay

public struct UpdateBackupFunc {
  public init(handle: @escaping (Data) -> Void) {
    self.handle = handle
  }

  public var handle: (Data) -> Void
}

extension UpdateBackupFunc {
  public static let unimplemented = UpdateBackupFunc(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension UpdateBackupFunc {
  func makeBindingsUpdateBackupFunc() -> BindingsUpdateBackupFuncProtocol {
    class CallbackObject: NSObject, BindingsUpdateBackupFuncProtocol {
      init(_ callback: UpdateBackupFunc) {
        self.callback = callback
      }

      let callback: UpdateBackupFunc

      func updateBackup(_ encryptedBackup: Data?) {
        guard let encryptedBackup = encryptedBackup else {
          fatalError("BindingsUpdateBackupFunc received `nil` encryptedBackup")
        }
        callback.handle(encryptedBackup)
      }
    }

    return CallbackObject(self)
  }
}
