import XXClient
import XCTestDynamicOverlay
import Foundation

public struct AuthCallbacksRegistry {
  public var register: (AuthCallbacks) -> Cancellable
  public var registered: () -> AuthCallbacks
}

extension AuthCallbacksRegistry {
  public static func live() -> AuthCallbacksRegistry {
    class Registry {
      var authCallbacks: [UUID: AuthCallbacks] = [:]
    }
    let registry = Registry()
    return AuthCallbacksRegistry(
      register: { authCallbacks in
        let id = UUID()
        registry.authCallbacks[id] = authCallbacks
        return Cancellable { registry.authCallbacks[id] = nil }
      },
      registered: {
        AuthCallbacks { callback in
          registry.authCallbacks.values.forEach { $0.handle(callback) }
        }
      }
    )
  }
}

extension AuthCallbacksRegistry {
  public static let unimplemented = AuthCallbacksRegistry(
    register: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {}),
    registered: XCTUnimplemented("\(Self.self)", placeholder: AuthCallbacks { _ in })
  )
}
