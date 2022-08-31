import Bindings
import XCTestDynamicOverlay

public struct NewGroupChat {
  public var run: (Int, GroupRequest, GroupChatProcessor) throws -> GroupChat

  public func callAsFunction(
    e2eId: Int,
    groupRequest: GroupRequest,
    groupChatProcessor: GroupChatProcessor
  ) throws -> GroupChat {
    try run(e2eId, groupRequest, groupChatProcessor)
  }
}

extension NewGroupChat {
  public static let live = NewGroupChat { e2eId, groupRequest, groupChatProcessor in
    var error: NSError?
    let bindingsGroupChat = BindingsNewGroupChat(
      e2eId,
      groupRequest.makeBindingsGroupRequest(),
      groupChatProcessor.makeBindingsGroupChatProcessor(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsGroupChat = bindingsGroupChat else {
      fatalError("BindingsNewGroupChat returned `nil` without providing error")
    }
    return .live(bindingsGroupChat)
  }
}

extension NewGroupChat {
  public static let unimplemented = NewGroupChat(
    run: XCTUnimplemented("\(Self.self)")
  )
}
