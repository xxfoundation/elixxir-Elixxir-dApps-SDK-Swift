import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct ReceiveFileHandler {
  public typealias OnError = (Error) -> Void

  public var run: (@escaping OnError) -> Cancellable

  public func callAsFunction(onError: @escaping OnError) -> Cancellable {
    run(onError)
  }
}

extension ReceiveFileHandler {
  public static func live(
    messenger: Messenger
  ) -> ReceiveFileHandler {
    ReceiveFileHandler { onError in
      messenger.registerReceiveFileCallback(.init { result in
        switch result {
        case .success(let file):
          // TODO:
          break

        case .failure(let error):
          onError(error)
        }
      })
    }
  }
}

extension ReceiveFileHandler {
  public static let unimplemented = ReceiveFileHandler(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
