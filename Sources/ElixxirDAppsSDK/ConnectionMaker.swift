//import Bindings
//
//public struct ConnectionMaker {
//  public var connect: (Bool, Data, Int) throws -> Connection
//
//  public func callAsFunction(
//    withAuthentication: Bool,
//    recipientContact: Data,
//    e2eId: Int
//  ) throws -> Connection {
//    try connect(withAuthentication, recipientContact, e2eId)
//  }
//}
//
//extension ConnectionMaker {
//  public static func live(bindingsClient: BindingsCmix) -> ConnectionMaker {
//    ConnectionMaker { withAuthentication, recipientContact, e2eId in
//      if withAuthentication {
//        return Connection.live(
//          bindingsAuthenticatedConnection: try bindingsClient.connect(
//            withAuthentication: e2eId,
//            recipientContact: recipientContact
//          )
//        )
//      } else {
//        return Connection.live(
//          bindingsConnection: try bindingsClient.connect(
//            e2eId,
//            recipientContact: recipientContact
//          )
//        )
//      }
//    }
//  }
//}
//
//#if DEBUG
//extension ConnectionMaker {
//  public static let failing = ConnectionMaker { _, _, _ in
//    struct NotImplemented: Error {}
//    throw NotImplemented()
//  }
//}
//#endif
