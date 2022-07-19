import Bindings

public struct ClientE2EIdProvider {
  public var get: () -> Int

  public func callAsFunction() -> Int {
    get()
  }
}

extension ClientE2EIdProvider {
  public static func live(bindingsClientE2E: BindingsE2e) -> ClientE2EIdProvider {
      ClientE2EIdProvider(get: bindingsClientE2E.getID)
  }
}

#if DEBUG
extension ClientE2EIdProvider {
  public static let failing = ClientE2EIdProvider {
    fatalError("Not implemented")
  }
}
#endif
