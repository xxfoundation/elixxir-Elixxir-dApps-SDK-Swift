import ComposableArchitecture

public struct MyContactState: Equatable {
  public init(
    id: UUID
  ) {
    self.id = id
  }

  public var id: UUID
}

public enum MyContactAction: Equatable {
  case viewDidLoad
}

public struct MyContactEnvironment {
  public init() {}
}

public let myContactReducer = Reducer<MyContactState, MyContactAction, MyContactEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    return .none
  }
}

#if DEBUG
extension MyContactEnvironment {
  public static let failing = MyContactEnvironment()
}
#endif
