import Foundation
import XCTestDynamicOverlay
import XXClient

public struct ReceiveFileCallbacksRegistry {
  public var register: (ReceiveFileCallback) -> Cancellable
  public var registered: () -> ReceiveFileCallback
}

extension ReceiveFileCallbacksRegistry {
  public static func live() -> ReceiveFileCallbacksRegistry {
    class Registry {
      var callbacks: [UUID: ReceiveFileCallback] = [:]
    }
    let registry = Registry()
    return ReceiveFileCallbacksRegistry(
      register: { callback in
        let id = UUID()
        registry.callbacks[id] = callback
        return Cancellable { registry.callbacks[id] = nil }
      },
      registered: {
        ReceiveFileCallback { result in
          registry.callbacks.values.forEach { $0.handle(result) }
        }
      }
    )
  }
}

extension ReceiveFileCallbacksRegistry {
  public static let unimplemented = ReceiveFileCallbacksRegistry(
    register: XCTUnimplemented("\(Self.self).register", placeholder: Cancellable {}),
    registered: XCTUnimplemented("\(Self.self).registered", placeholder: .unimplemented)
  )
}
