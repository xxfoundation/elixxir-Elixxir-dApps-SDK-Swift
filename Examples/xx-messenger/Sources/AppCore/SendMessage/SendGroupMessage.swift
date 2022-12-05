import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct SendGroupMessage {
  public typealias OnError = (Error) -> Void
  public typealias Completion = () -> Void

  public var run: (String, Data, @escaping OnError, @escaping Completion) -> Void

  public func callAsFunction(
    text: String,
    to groupId: Data,
    onError: @escaping OnError,
    completion: @escaping Completion
  ) {
    run(text, groupId, onError, completion)
  }
}

extension SendGroupMessage {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB,
    now: @escaping () -> Date
  ) -> SendGroupMessage {
    SendGroupMessage { text, groupId, onError, completion in
      // TODO: implement sending group message
      struct Unimplemented: Error, LocalizedError {
        var errorDescription: String? { "SendGroupMessage is not implemented!" }
      }
      onError(Unimplemented())
      completion()
    }
  }
}

extension SendGroupMessage {
  public static let unimplemented = SendGroupMessage(
    run: XCTUnimplemented("\(Self.self)")
  )
}
