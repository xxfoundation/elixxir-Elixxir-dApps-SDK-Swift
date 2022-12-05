import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ChatComponent: ReducerProtocol {
  public struct State: Equatable, Identifiable {
    public enum ID: Equatable, Hashable {
      case contact(XXModels.Contact.ID)
    }

    public struct Message: Equatable, Identifiable {
      public init(
        id: Int64,
        date: Date,
        senderId: Data,
        text: String,
        status: XXModels.Message.Status,
        fileTransfer: XXModels.FileTransfer? = nil
      ) {
        self.id = id
        self.date = date
        self.senderId = senderId
        self.text = text
        self.status = status
        self.fileTransfer = fileTransfer
      }

      public var id: Int64
      public var date: Date
      public var senderId: Data
      public var text: String
      public var status: XXModels.Message.Status
      public var fileTransfer: XXModels.FileTransfer?
    }

    public init(
      id: ID,
      myContactId: Data? = nil,
      messages: IdentifiedArrayOf<Message> = [],
      failure: String? = nil,
      sendFailure: String? = nil,
      text: String = ""
    ) {
      self.id = id
      self.myContactId = myContactId
      self.messages = messages
      self.failure = failure
      self.sendFailure = sendFailure
      self.text = text
    }

    public var id: ID
    public var myContactId: Data?
    public var messages: IdentifiedArrayOf<Message>
    public var failure: String?
    public var sendFailure: String?
    @BindableState public var text: String
  }

  public enum Action: Equatable, BindableAction {
    case start
    case didFetchMessages(IdentifiedArrayOf<State.Message>)
    case sendTapped
    case sendFailed(String)
    case imagePicked(Data)
    case dismissSendFailureTapped
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.sendMessage) var sendMessage: SendMessage
  @Dependency(\.app.sendImage) var sendImage: SendImage
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      enum FetchEffectId {}

      switch action {
      case .start:
        state.failure = nil
        do {
          let myContactId = try messenger.e2e.tryGet().getContact().getId()
          state.myContactId = myContactId
          let queryChat: XXModels.Message.Query.Chat
          let receivedFileTransfersQuery: XXModels.FileTransfer.Query
          let sentFileTransfersQuery: XXModels.FileTransfer.Query
          switch state.id {
          case .contact(let contactId):
            queryChat = .direct(myContactId, contactId)
            receivedFileTransfersQuery = .init(
              contactId: contactId,
              isIncoming: true
            )
            sentFileTransfersQuery = .init(
              contactId: myContactId,
              isIncoming: false
            )
          }
          let messagesQuery = XXModels.Message.Query(chat: queryChat)
          return Publishers.CombineLatest3(
            try db().fetchMessagesPublisher(messagesQuery),
            try db().fetchFileTransfersPublisher(receivedFileTransfersQuery),
            try db().fetchFileTransfersPublisher(sentFileTransfersQuery)
          )
          .map { messages, receivedFileTransfers, sentFileTransfers in
            (messages, receivedFileTransfers + sentFileTransfers)
          }
          .assertNoFailure()
          .map { messages, fileTransfers in
            messages.compactMap { message in
              guard let id = message.id else { return nil }
              return State.Message(
                id: id,
                date: message.date,
                senderId: message.senderId,
                text: message.text,
                status: message.status,
                fileTransfer: fileTransfers.first { $0.id == message.fileTransferId }
              )
            }
          }
          .removeDuplicates()
          .map { IdentifiedArrayOf<State.Message>(uniqueElements: $0) }
          .map(Action.didFetchMessages)
          .subscribe(on: bgQueue)
          .receive(on: mainQueue)
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
            sendMessage(
              text: text,
              to: recipientId,
              onError: { error in
                subscriber.send(.sendFailed(error.localizedDescription))
              },
              completion: {
                subscriber.send(completion: .finished)
              }
            )
          }
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .sendFailed(let failure):
        state.sendFailure = failure
        return .none

      case .imagePicked(let data):
        let chatId = state.id
        return Effect.run { subscriber in
          switch chatId {
          case .contact(let recipientId):
            sendImage(
              data,
              to: recipientId,
              onError: { error in
                subscriber.send(.sendFailed(error.localizedDescription))
              },
              completion: {
                subscriber.send(completion: .finished)
              }
            )
          }
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .dismissSendFailureTapped:
        state.sendFailure = nil
        return .none

      case .binding(_):
        return .none
      }
    }
  }
}
