import Bindings

public struct ClientProcessStatusProvider {
  public var get: () -> Bool

  public func callAsFunction() -> Bool {
    get()
  }
}

extension ClientProcessStatusProvider {
  public static func live(bindingsClient: BindingsClient) -> ClientProcessStatusProvider {
    ClientProcessStatusProvider(get: bindingsClient.hasRunningProcessies)
  }
}

#if DEBUG
extension ClientProcessStatusProvider {
  public static let failing = ClientProcessStatusProvider {
    fatalError("Not implemented")
  }
}
#endif
