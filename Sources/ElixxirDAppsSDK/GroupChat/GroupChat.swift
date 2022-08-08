import Bindings

public struct GroupChat {
  public var getGroup: GroupChatGetGroup
  public var getGroups: GroupChatGetGroups
  public var joinGroup: GroupChatJoinGroup
  public var leaveGroup: GroupChatLeaveGroup
  public var numGroups: GroupChatNumGroups
  public var resendRequest: GroupChatResendRequest
  public var send: GroupChatSend
}

extension GroupChat {
  public static func live(_ bindingsGroupChat: BindingsGroupChat) -> GroupChat {
    GroupChat(
      getGroup: .live(bindingsGroupChat),
      getGroups: .live(bindingsGroupChat),
      joinGroup: .live(bindingsGroupChat),
      leaveGroup: .live(bindingsGroupChat),
      numGroups: .live(bindingsGroupChat),
      resendRequest: .live(bindingsGroupChat),
      send: .live(bindingsGroupChat)
    )
  }
}

extension GroupChat {
  public static let unimplemented = GroupChat(
    getGroup: .unimplemented,
    getGroups: .unimplemented,
    joinGroup: .unimplemented,
    leaveGroup: .unimplemented,
    numGroups: .unimplemented,
    resendRequest: .unimplemented,
    send: .unimplemented
  )
}
