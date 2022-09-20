import ComposableArchitecture
import XCTestDynamicOverlay

public struct MyContactState: Equatable {
  public init() {}
}

public enum MyContactAction: Equatable {
  case start
}

public struct MyContactEnvironment {
  public init() {}
}

#if DEBUG
extension MyContactEnvironment {
  public static let unimplemented = MyContactEnvironment()
}
#endif

public let myContactReducer = Reducer<MyContactState, MyContactAction, MyContactEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
