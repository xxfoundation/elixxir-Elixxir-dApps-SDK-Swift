import Bindings

public struct ClientCreator {
  public var create: (URL, Data, Data) throws -> Void

  public func callAsFunction(directoryURL: URL, ndf: Data, password: Data) throws {
    try create(directoryURL, ndf, password)
  }
}

extension ClientCreator {
  public static let live = ClientCreator { directoryURL, ndf, password in
    var error: NSError?
    let network = String(data: ndf, encoding: .utf8)!
    let created = BindingsNewClient(network, directoryURL.path, password, nil, &error)
    if let error = error {
      throw error
    }
    if !created {
      fatalError("BindingsNewClient returned `false` without providing error")
    }
  }
}

#if DEBUG
extension ClientCreator {
  public static let failing = ClientCreator { _, _, _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
