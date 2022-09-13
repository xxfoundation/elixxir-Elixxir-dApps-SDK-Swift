import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

public struct ChatState: Equatable, Identifiable {
  public enum ID: Equatable, Hashable {
    case contact(Data)
  }

  public init(id: ID) {
    self.id = id
  }

  public var id: ID
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
