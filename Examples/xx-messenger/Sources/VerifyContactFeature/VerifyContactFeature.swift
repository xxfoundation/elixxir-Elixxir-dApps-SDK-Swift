import ComposableArchitecture
import XCTestDynamicOverlay

public struct VerifyContactState: Equatable {
  public init() {}
}

public enum VerifyContactAction: Equatable {
  case start
}

public struct VerifyContactEnvironment {
  public init() {}
}

#if DEBUG
extension VerifyContactEnvironment {
  public static let unimplemented = VerifyContactEnvironment()
}
#endif

public let verifyContactReducer = Reducer<VerifyContactState, VerifyContactAction, VerifyContactEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
