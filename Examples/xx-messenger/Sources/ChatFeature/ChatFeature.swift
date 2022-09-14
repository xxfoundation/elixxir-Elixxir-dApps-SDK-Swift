import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ChatState: Equatable, Identifiable {
  public enum ID: Equatable, Hashable {
    case contact(Data)
  }

  public struct Message: Equatable, Identifiable {
    public init(
      id: Int64,
      date: Date,
      senderId: Data,
      text: String
    ) {
      self.id = id
      self.date = date
      self.senderId = senderId
      self.text = text
    }

    public var id: Int64
    public var date: Date
    public var senderId: Data
    public var text: String
  }

  public init(
    id: ID,
    myContactId: Data? = nil,
    messages: IdentifiedArrayOf<Message> = [],
    failure: String? = nil,
    text: String = ""
  ) {
    self.id = id
    self.myContactId = myContactId
    self.messages = messages
    self.failure = failure
    self.text = text
  }

  public var id: ID
  public var myContactId: Data?
  public var messages: IdentifiedArrayOf<Message>
  public var failure: String?
  @BindableState public var text: String
}

public enum ChatAction: Equatable, BindableAction {
  case start
  case didFetchMessages(IdentifiedArrayOf<ChatState.Message>)
  case sendTapped
  case binding(BindingAction<ChatState>)
}

public struct ChatEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    sendMessage: SendMessage,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.db = db
    self.sendMessage = sendMessage
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var sendMessage: SendMessage
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension ChatEnvironment {
  public static let unimplemented = ChatEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    sendMessage: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let chatReducer = Reducer<ChatState, ChatAction, ChatEnvironment>
{ state, action, env in
  enum FetchEffectId {}

  switch action {
  case .start:
    state.failure = nil
    do {
      let myContactId = try env.messenger.e2e.tryGet().getContact().getId()
      state.myContactId = myContactId
      let queryChat: XXModels.Message.Query.Chat
      switch state.id {
      case .contact(let contactId):
        queryChat = .direct(myContactId, contactId)
      }
      let query = XXModels.Message.Query(chat: queryChat)
      return try env.db().fetchMessagesPublisher(query)
        .assertNoFailure()
        .map { messages in
          messages.compactMap { message in
            guard let id = message.id else { return nil }
            return ChatState.Message(
              id: id,
              date: message.date,
              senderId: message.senderId,
              text: message.text
            )
          }
        }
        .map { IdentifiedArrayOf<ChatState.Message>(uniqueElements: $0) }
        .map(ChatAction.didFetchMessages)
        .subscribe(on: env.bgQueue)
        .receive(on: env.mainQueue)
        .eraseToEffect()
        .cancellable(id: FetchEffectId.self, cancelInFlight: true)
    } catch {
      state.failure = error.localizedDescription
      return .none
    }

  case .didFetchMessages(let messages):
    state.messages = messages
    return .none

  case .sendTapped:
    let text = state.text
    let chatId = state.id
    state.text = ""
    return Effect.run { subscriber in
      switch chatId {
      case .contact(let recipientId):
        env.sendMessage(
          text: text,
          to: recipientId,
          onError: { error in
            // TODO: handle error
            print("^^^ ERROR: \(error)")
          }
        )
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .binding(_):
    return .none
  }
}
.binding()
