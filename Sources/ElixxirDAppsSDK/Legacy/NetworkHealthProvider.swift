import Bindings

public struct NetworkHealthProvider {
  public var get: () -> Bool

  public func callAsFunction() -> Bool {
    get()
  }
}

extension NetworkHealthProvider {
  public static func live(bindingsClient: BindingsCmix) -> NetworkHealthProvider {
    NetworkHealthProvider(get: bindingsClient.isNetworkHealthy)
  }
}

#if DEBUG
extension NetworkHealthProvider {
  public static let failing = NetworkHealthProvider {
    fatalError("Not implemented")
  }
}
#endif
