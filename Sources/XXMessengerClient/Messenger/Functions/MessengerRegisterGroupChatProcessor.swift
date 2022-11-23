import XCTestDynamicOverlay
import XXClient

public struct MessengerRegisterGroupChatProcessor {
  public var run: (GroupChatProcessor) -> Cancellable

  public func callAsFunction(_ processor: GroupChatProcessor) -> Cancellable {
    run(processor)
  }
}

extension MessengerRegisterGroupChatProcessor {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegisterGroupChatProcessor {
    MessengerRegisterGroupChatProcessor { processor in
      env.groupChatProcessors.register(processor)
    }
  }
}

extension MessengerRegisterGroupChatProcessor {
  public static let unimplemented = MessengerRegisterGroupChatProcessor(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
