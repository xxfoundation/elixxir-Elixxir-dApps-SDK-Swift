import Bindings
import XCTestDynamicOverlay

public struct Listen {
  public var run: (Int, String, SingleUseCallback) throws -> Cancellable

  public func callAsFunction(
    e2eId: Int,
    tag: String,
    callback: SingleUseCallback
  ) throws -> Cancellable {
    try run(e2eId, tag, callback)
  }
}

extension Listen {
  public static let live = Listen { e2eId, tag, callback in
    var error: NSError?
    let stopper = BindingsListen(
      e2eId,
      tag,
      callback.makeBindingsSingleUseCallback(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let stopper = stopper else {
      fatalError("BindingsListen returned `nil` without providing error")
    }
    return Cancellable {
      stopper.stop()
    }
  }
}

extension Listen {
  public static let unimplemented = Listen(
    run: XCTUnimplemented("\(Self.self)")
  )
}
