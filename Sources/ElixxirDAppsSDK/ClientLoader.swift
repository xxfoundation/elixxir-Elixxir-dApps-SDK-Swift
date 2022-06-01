import Bindings

public struct ClientLoader {
  public var load: (URL, Data) throws -> Client

  public func callAsFunction(directoryURL: URL, password: Data) throws -> Client {
    try load(directoryURL, password)
  }
}

extension ClientLoader {
  public static let live = ClientLoader { directoryURL, password in
    var error: NSError?
    let bindingsClient = BindingsLogin(directoryURL.path, password, &error)
    if let error = error { throw error }
    guard let bindingsClient = bindingsClient else {
      throw BindingsLoginUnknownError()
    }
    return Client.live(bindingsClient: bindingsClient)
  }
}

#if DEBUG
extension ClientLoader {
  public static let failing = ClientLoader { _, _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
