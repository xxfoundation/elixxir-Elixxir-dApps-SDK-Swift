import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct VerifyContactComponent: ReducerProtocol {
  public struct State: Equatable {
    public enum Result: Equatable {
      case success(Bool)
      case failure(String)
    }

    public init(
      contact: XXClient.Contact,
      isVerifying: Bool = false,
      result: Result? = nil
    ) {
      self.contact = contact
      self.isVerifying = isVerifying
      self.result = result
    }

    public var contact: XXClient.Contact
    public var isVerifying: Bool
    public var result: Result?
  }

  public enum Action: Equatable {
    case verifyTapped
    case didVerify(State.Result)
  }

  public init() {}

  @Dependency(\.appDependencies.messenger) var messenger: Messenger
  @Dependency(\.appDependencies.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.appDependencies.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.appDependencies.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .verifyTapped:
      state.isVerifying = true
      state.result = nil
      return Effect.result { [state] in
        func updateStatus(_ status: XXModels.Contact.AuthStatus) throws {
          try db().bulkUpdateContacts.callAsFunction(
            .init(id: [try state.contact.getId()]),
            .init(authStatus: status)
          )
        }
        do {
          try updateStatus(.verificationInProgress)
          let result = try messenger.verifyContact(state.contact)
          try updateStatus(result ? .verified : .verificationFailed)
          return .success(.didVerify(.success(result)))
        } catch {
          try? updateStatus(.verificationFailed)
          return .success(.didVerify(.failure(error.localizedDescription)))
        }
      }
      .subscribe(on: bgQueue)
      .receive(on: mainQueue)
      .eraseToEffect()

    case .didVerify(let result):
      state.isVerifying = false
      state.result = result
      return .none
    }
  }
}
