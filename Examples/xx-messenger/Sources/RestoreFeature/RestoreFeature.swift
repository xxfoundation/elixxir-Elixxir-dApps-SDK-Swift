import ComposableArchitecture

public struct RestoreState: Equatable {
  public init() {}
}

public enum RestoreAction: Equatable {
  case finished
}

public struct RestoreEnvironment {
  public init() {}
}

extension RestoreEnvironment {
  public static let unimplemented = RestoreEnvironment()
}

public let restoreReducer = Reducer<RestoreState, RestoreAction, RestoreEnvironment>.empty
