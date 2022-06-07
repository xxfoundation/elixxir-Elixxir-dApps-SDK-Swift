import Bindings

public struct ConnectionMaker {
  public var connect: (Bool, Data, Identity) throws -> Connection

  public func callAsFunction(
    withAuthentication: Bool,
    recipientContact: Data,
    myIdentity: Identity
  ) throws -> Connection {
    try connect(withAuthentication, recipientContact, myIdentity)
  }
}

extension ConnectionMaker {
  public static func live(bindingsClient: BindingsClient) -> ConnectionMaker {
    ConnectionMaker { withAuthentication, recipientContact, myIdentity in
      let encoder = JSONEncoder()
      let myIdentityData = try encoder.encode(myIdentity)
      if withAuthentication {
        return Connection.live(
          bindingsAuthenticatedConnection: try bindingsClient.connect(
            withAuthentication: recipientContact,
            myIdentity: myIdentityData
          )
        )
      } else {
        return Connection.live(
          bindingsConnection: try bindingsClient.connect(
            recipientContact,
            myIdentity: myIdentityData
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
