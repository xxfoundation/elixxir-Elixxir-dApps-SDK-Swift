import XCTestDynamicOverlay
import XXClient

public struct MessengerRegisterGroupRequestHandler {
  public var run: (GroupRequest) -> Cancellable

  public func callAsFunction(_ handler: GroupRequest) -> Cancellable {
    run(handler)
  }
}

extension MessengerRegisterGroupRequestHandler {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegisterGroupRequestHandler {
    MessengerRegisterGroupRequestHandler { handler in
      env.groupRequests.register(handler)
    }
  }
}

extension MessengerRegisterGroupRequestHandler {
  public static let unimplemented = MessengerRegisterGroupRequestHandler(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
