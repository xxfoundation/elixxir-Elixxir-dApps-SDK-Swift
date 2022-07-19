import Bindings

public struct ConnectionPartnerProvider {
  public var get: () -> Data

  public func callAsFunction() -> Data {
    get()
  }
}

extension ConnectionPartnerProvider {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> ConnectionPartnerProvider {
    ConnectionPartnerProvider {
      guard let data = bindingsConnection.getPartner() else {
        fatalError("BindingsConnection.getPartner returned `nil`")
      }
      return data
    }
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> ConnectionPartnerProvider {
    ConnectionPartnerProvider {
      guard let data = bindingsAuthenticatedConnection.getPartner() else {
        fatalError("BindingsAuthenticatedConnection.getPartner returned `nil`")
      }
      return data
    }
  }
}

#if DEBUG
extension ConnectionPartnerProvider {
  public static let failing = ConnectionPartnerProvider {
    fatalError("Not implemented")
  }
}
#endif
