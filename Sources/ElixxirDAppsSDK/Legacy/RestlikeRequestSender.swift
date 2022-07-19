//import Bindings
//
//public struct RestlikeRequestSender {
//  public var send: (Int, Int, RestlikeMessage) throws -> RestlikeMessage
//
//  public func callAsFunction(
//    clientId: Int,
//    connectionId: Int,
//    request: RestlikeMessage
//  ) throws -> RestlikeMessage {
//    try send(clientId, connectionId, request)
//  }
//}
//
//extension RestlikeRequestSender {
//  public static func live(authenticated: Bool) -> RestlikeRequestSender {
//    RestlikeRequestSender { clientId, connectionId, request in
//      let encoder = JSONEncoder()
//      let requestData = try encoder.encode(request)
//      var error: NSError?
//      let responseData: Data?
//      if authenticated {
//        responseData = BindingsRestlikeRequestAuth(clientId, connectionId, requestData, &error)
//      } else {
//        responseData = BindingsRestlikeRequest(clientId, connectionId, requestData, &error)
//      }
//      if let error = error {
//        throw error
//      }
//      guard let responseData = responseData else {
//        let functionName = "BindingsRestlikeRequest\(authenticated ? "Auth" : "")"
//        fatalError("\(functionName) returned `nil` without providing error")
//      }
//      let decoder = JSONDecoder()
//      let response = try decoder.decode(RestlikeMessage.self, from: responseData)
//      return response
//    }
//  }
//}
//
//#if DEBUG
//extension RestlikeRequestSender {
//  public static let failing = RestlikeRequestSender { _, _, _ in
//    struct NotImplemented: Error {}
//    throw NotImplemented()
//  }
//}
//#endif
