import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct AuthCallbackHandler {
  public typealias OnError = (Error) -> Void

  public var run: (@escaping OnError) -> Cancellable

  public func callAsFunction(onError: @escaping OnError) -> Cancellable {
    run(onError)
  }
}

extension AuthCallbackHandler {
  public static func live(
    messenger: Messenger,
    handleRequest: AuthCallbackHandlerRequest,
    handleConfirm: AuthCallbackHandlerConfirm,
    handleReset: AuthCallbackHandlerReset
  ) -> AuthCallbackHandler {
    AuthCallbackHandler { onError in
      messenger.registerAuthCallbacks(.init { callback in
        do {
          switch callback {
          case .request(let contact, _, _, _):
            try handleRequest(contact)

          case .confirm(let contact, _, _, _):
            try handleConfirm(contact)

          case .reset(let contact, _, _, _):
            try handleReset(contact)
          }
        } catch {
          onError(error)
        }
      })
    }
  }
}

extension AuthCallbackHandler {
  public static let unimplemented = AuthCallbackHandler(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
