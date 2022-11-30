import ComposableArchitecture

public struct NewGroupComponent: ReducerProtocol {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case start
    case didFinish
  }

  public init() {}

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .start:
      return .none

    case .didFinish:
      return .none
    }
  }
}
