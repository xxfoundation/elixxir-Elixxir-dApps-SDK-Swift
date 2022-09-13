import Foundation
import XCTestDynamicOverlay
import XXClient

public struct ListenersRegistry {
  public var register: (Listener) -> Cancellable
  public var registered: () -> Listener
}

extension ListenersRegistry {
  public static func live() -> ListenersRegistry {
    class Registry {
      var listeners: [UUID: Listener] = [:]
    }
    let registry = Registry()
    return ListenersRegistry(
      register: { listener in
        let id = UUID()
        registry.listeners[id] = listener
        return Cancellable { registry.listeners[id] = nil }
      },
      registered: {
        Listener(name: "listeners-registry") { message in
          registry.listeners.values.forEach { $0.handle(message) }
        }
      }
    )
  }
}

extension ListenersRegistry {
  public static let unimplemented = ListenersRegistry(
    register: XCTUnimplemented("\(Self.self).register", placeholder: Cancellable {}),
    registered: XCTUnimplemented("\(Self.self).registered", placeholder: Listener(
      name: "unimplemented",
      handle: { _ in }
    ))
  )
}
