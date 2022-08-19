import Bindings
import XCTestDynamicOverlay

public struct E2EAddPartnerCallback {
  public var run: (Data, AuthCallbacks) throws -> Cancellable

  public func callAsFunction(
    partnerId: Data,
    callbacks: AuthCallbacks
  ) throws -> Cancellable {
    try run(partnerId, callbacks)
  }
}

extension E2EAddPartnerCallback {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EAddPartnerCallback {
    E2EAddPartnerCallback { partnerId, callbacks in
      try bindingsE2E.addPartnerCallback(
        partnerId,
        cb: callbacks.makeBindingsAuthCallbacks()
      )
      return Cancellable {
        do {
          try bindingsE2E.deletePartnerCallback(partnerId)
        } catch {
          fatalError("BindingsE2e.deletePartnerCallback returned error: \(error)")
        }
      }
    }
  }
}

extension E2EAddPartnerCallback {
  public static let unimplemented = E2EAddPartnerCallback(
    run: XCTUnimplemented("\(Self.self)")
  )
}
