import ComposableArchitecture

public struct GroupsComponent: ReducerProtocol {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case start
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .start:
        return .none
      }
    }
  }
}
