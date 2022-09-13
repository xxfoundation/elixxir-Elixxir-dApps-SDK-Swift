import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

public struct ChatState: Equatable, Identifiable {
  public enum ID: Equatable, Hashable {
    case contact(Data)
  }

  public struct Message: Equatable, Identifiable {
    public init(
      id: Data,
      date: Date,
      senderId: Data,
      text: String
    ) {
      self.id = id
      self.date = date
      self.senderId = senderId
      self.text = text
    }

    public var id: Data
    public var date: Date
    public var senderId: Data
    public var text: String
  }

  public init(
    id: ID,
    myContactId: Data? = nil,
    messages: IdentifiedArrayOf<Message> = []
  ) {
    self.id = id
    self.myContactId = myContactId
    self.messages = messages
  }

  public var id: ID
  public var myContactId: Data?
  public var messages: IdentifiedArrayOf<Message>
}

public enum ChatAction: Equatable {
  case start
}

public struct ChatEnvironment {
  public init() {}
}

#if DEBUG
extension ChatEnvironment {
  public static let unimplemented = ChatEnvironment()
}
#endif

public let chatReducer = Reducer<ChatState, ChatAction, ChatEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
