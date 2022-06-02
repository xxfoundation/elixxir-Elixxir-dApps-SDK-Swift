import Bindings

public struct NetworkFollowerStatusProvider {
  public var status: () -> NetworkFollowerStatus

  public func callAsFunction() -> NetworkFollowerStatus {
    status()
  }
}

extension NetworkFollowerStatusProvider {
  public static func live(bindingsClient: BindingsClient) -> NetworkFollowerStatusProvider {
    NetworkFollowerStatusProvider {
      let rawValue = bindingsClient.networkFollowerStatus()
      return NetworkFollowerStatus(rawValue: rawValue)
    }
  }
}

#if DEBUG
extension NetworkFollowerStatusProvider {
  public static let failing = NetworkFollowerStatusProvider {
    .unknown(code: -1)
  }
}
#endif
