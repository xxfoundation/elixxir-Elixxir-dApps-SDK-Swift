import Bindings
import XCTestDynamicOverlay

public struct RestlikeRequest {
  public var run: (Bool, Int, Int, RestlikeMessage, Data) throws -> RestlikeMessage

  public func callAsFunction(
    authenticated: Bool,
    clientId: Int,
    connectionId: Int,
    request: RestlikeMessage,
    e2eParams: Data
  ) throws -> RestlikeMessage {
    try run(authenticated, clientId, connectionId, request, e2eParams)
  }
}

extension RestlikeRequest {
  public static func live() -> RestlikeRequest {
    RestlikeRequest { authenticated, clientId, connectionId, request, e2eParams in
      let requestData = try request.encode()
      var error: NSError?
      let responseData: Data?
      if authenticated {
        responseData = BindingsRestlikeRequest(
          clientId,
          connectionId,
          requestData,
          e2eParams,
          &error
        )
      } else {
        responseData = BindingsRestlikeRequestAuth(
          clientId,
          connectionId,
          requestData,
          e2eParams,
          &error
        )
      }
      if let error = error {
        throw error
      }
      guard let responseData = responseData else {
        let functionName = "BindingsRestlikeRequest\(authenticated ? "Auth" : "")"
        fatalError("\(functionName) returned `nil` without providing error")
      }
      return try RestlikeMessage.decode(responseData)
    }
  }
}

extension RestlikeRequest {
  public static let unimplemented = RestlikeRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
