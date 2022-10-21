import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct CheckContactAuthComponent: ReducerProtocol {
  public struct State: Equatable {
    public enum Result: Equatable {
      case success(Bool)
      case failure(String)
    }

    public init(
      contact: XXClient.Contact,
      isChecking: Bool = false,
      result: Result? = nil
    ) {
      self.contact = contact
      self.isChecking = isChecking
      self.result = result
    }

    public var contact: XXClient.Contact
    public var isChecking: Bool
    public var result: Result?
  }

  public enum Action: Equatable {
    case checkTapped
    case didCheck(State.Result)
  }

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public init() {}

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .checkTapped:
      state.isChecking = true
      state.result = nil
      return Effect.result { [state] in
        do {
          let e2e = try messenger.e2e.tryGet()
          let contactId = try state.contact.getId()
          let result = try e2e.hasAuthenticatedChannel(partnerId: contactId)
          try db().bulkUpdateContacts.callAsFunction(
            .init(id: [contactId]),
            .init(authStatus: result ? .friend : .stranger)
          )
          return .success(.didCheck(.success(result)))
        } catch {
          return .success(.didCheck(.failure(error.localizedDescription)))
        }
      }
      .subscribe(on: bgQueue)
      .receive(on: mainQueue)
      .eraseToEffect()

    case .didCheck(let result):
      state.isChecking = false
      state.result = result
      return .none
    }
  }
}
