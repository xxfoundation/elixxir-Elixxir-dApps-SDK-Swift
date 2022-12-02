import ComposableArchitecture
import XXModels

public struct GroupComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      group: XXModels.Group
    ) {
      self.group = group
    }

    public var group: XXModels.Group
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
