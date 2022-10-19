import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct SendImage {
  public typealias OnError = (Error) -> Void
  public typealias Completion = () -> Void

  public var run: (Data, Data, @escaping OnError, @escaping Completion) -> Void

  public func callAsFunction(
    _ image: Data,
    to recipientId: Data,
    onError: @escaping OnError,
    completion: @escaping Completion
  ) {
    run(image, recipientId, onError, completion)
  }
}

extension SendImage {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB,
    now: @escaping () -> Date
  ) -> SendImage {
    SendImage { image, recipientId, onError, completion in
      // TODO: implement sending image
      completion()
    }
  }
}

extension SendImage {
  public static let unimplemented = SendImage(
    run: XCTUnimplemented("\(Self.self)")
  )
}
