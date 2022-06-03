import Bindings

public struct NetworkWaiter {
  public var wait: (_ timeoutMS: Int) -> Bool

  public func callAsFunction(timeoutMS: Int) -> Bool {
    wait(timeoutMS)
  }
}

extension NetworkWaiter {
  public static func live(bindingsClient: BindingsClient) -> NetworkWaiter {
    NetworkWaiter { timeoutMS in
      bindingsClient.wait(forNetwork: timeoutMS)
    }
  }
}

#if DEBUG
extension NetworkWaiter {
  public static let failing = NetworkWaiter { _ in
    fatalError("Not implemented")
  }
}
#endif
