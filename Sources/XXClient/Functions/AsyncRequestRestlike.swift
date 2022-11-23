import Bindings
import XCTestDynamicOverlay

public struct AsyncRequestRestlike {
  public var run: (Int, Contact, RestlikeMessage, Data, RestlikeCallback) throws -> Void

  public func callAsFunction(
    e2eId: Int,
    recipient: Contact,
    request: RestlikeMessage,
    paramsJSON: Data,
    callback: RestlikeCallback
  ) throws {
    try run(e2eId, recipient, request, paramsJSON, callback)
  }
}

extension AsyncRequestRestlike {
  public static let live = AsyncRequestRestlike { e2dId, recipient, request, paramsJSON, callback in
    var error: NSError?
    let result = BindingsAsyncRequestRestLike(
      e2dId,
      recipient.data,
      try request.encode(),
      paramsJSON,
      callback.makeBindingsRestlikeCallback(),
      &error
    )
    if let error = error {
      throw error
    }
    guard result else {
      fatalError("BindingsAsyncRequestRestLike returned `false` without providing error")
    }
  }
}

extension AsyncRequestRestlike {
  public static let unimplemented = AsyncRequestRestlike(
    run: XCTUnimplemented("\(Self.self)")
  )
}
