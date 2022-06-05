import Bindings

public struct ConnectionMaker {
  public var connect: (Bool, Data, Data) throws -> Connection

  public func callAsFunction(
    withAuthentication: Bool,
    recipientContact: Data,
    myIdentity: Data
  ) throws -> Connection {
    try connect(withAuthentication, recipientContact, myIdentity)
  }
}

extension ConnectionMaker {
  public static func live(bindingsClient: BindingsClient) -> ConnectionMaker {
    ConnectionMaker { withAuthentication, recipientContact, myIdentity in
      if !withAuthentication {
        return Connection.live(
          bindingsConnection: try bindingsClient.connect(
            recipientContact,
            myIdentity: myIdentity
          )
        )
      } else {
        return Connection.live(
          bindingsAuthenticatedConnection: try bindingsClient.connect(
            withAuthentication: recipientContact,
            myIdentity: myIdentity
          )
        )
      }
    }
  }
}

#if DEBUG
extension ConnectionMaker {
  public static let failing = ConnectionMaker { _, _, _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
