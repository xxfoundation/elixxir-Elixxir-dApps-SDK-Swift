import Bindings
import XCTestDynamicOverlay

public struct RequestRestlike {
  public var run: (Int, Contact, RestlikeMessage, Data) throws -> RestlikeMessage

  public func callAsFunction(
    e2eId: Int,
    recipient: Contact,
    request: RestlikeMessage,
    paramsJSON: Data
  ) throws -> RestlikeMessage {
    try run(e2eId, recipient, request, paramsJSON)
  }
}

extension RequestRestlike {
  public static let live = RequestRestlike { e2dId, recipient, request, paramsJSON in
    var error: NSError?
    let responseData = BindingsRequestRestLike(
      e2dId,
      recipient.data,
      try request.encode(),
      paramsJSON,
      &error
    )
    if let error = error {
      throw error
    }
    guard let responseData = responseData else {
      fatalError("BindingsRequestRestLike returned `nil` without providing error")
    }
    return try RestlikeMessage.decode(responseData)
  }
}

extension RequestRestlike {
  public static let unimplemented = RequestRestlike(
    run: XCTUnimplemented("\(Self.self)")
  )
}
