import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct ContactLookupComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      id: Data,
      isLookingUp: Bool = false,
      failure: String? = nil
    ) {
      self.id = id
      self.isLookingUp = isLookingUp
      self.failure = failure
    }

    public var id: Data
    public var isLookingUp: Bool
    public var failure: String?
  }

  public enum Action: Equatable {
    case lookupTapped
    case didLookup(XXClient.Contact)
    case didFail(NSError)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger
  @Dependency(\.app.mainQueue) var mainQueue
  @Dependency(\.app.bgQueue) var bgQueue

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .lookupTapped:
      state.isLookingUp = true
      state.failure = nil
      return Effect.result { [state] in
        do {
          let contact = try messenger.lookupContact(id: state.id)
          return .success(.didLookup(contact))
        } catch {
          return .success(.didFail(error as NSError))
        }
      }
      .subscribe(on: bgQueue)
      .receive(on: mainQueue)
      .eraseToEffect()

    case .didLookup(_):
      state.isLookingUp = false
      state.failure = nil
      return .none

    case .didFail(let error):
      state.isLookingUp = false
      state.failure = error.localizedDescription
      return .none
    }
  }
}
