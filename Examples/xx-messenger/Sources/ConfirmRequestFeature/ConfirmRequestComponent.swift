import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ConfirmRequestComponent: ReducerProtocol {
  public struct State: Equatable {
    public enum Result: Equatable {
      case success
      case failure(String)
    }

    public init(
      contact: XXClient.Contact,
      isConfirming: Bool = false,
      result: Result? = nil
    ) {
      self.contact = contact
      self.isConfirming = isConfirming
      self.result = result
    }

    public var contact: XXClient.Contact
    public var isConfirming: Bool
    public var result: Result?
  }

  public enum Action: Equatable {
    case confirmTapped
    case didConfirm(State.Result)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .confirmTapped:
      state.isConfirming = true
      state.result = nil
      return Effect.result { [state] in
        func updateStatus(_ status: XXModels.Contact.AuthStatus) throws {
          try db().bulkUpdateContacts.callAsFunction(
            .init(id: [try state.contact.getId()]),
            .init(authStatus: status)
          )
        }
        do {
          try updateStatus(.confirming)
          let e2e = try messenger.e2e.tryGet()
          _ = try e2e.confirmReceivedRequest(partner: state.contact)
          try updateStatus(.friend)
          return .success(.didConfirm(.success))
        } catch {
          try? updateStatus(.confirmationFailed)
          return .success(.didConfirm(.failure(error.localizedDescription)))
        }
      }
      .subscribe(on: bgQueue)
      .receive(on: mainQueue)
      .eraseToEffect()

    case .didConfirm(let result):
      state.isConfirming = false
      state.result = result
      return .none
    }
  }
}
