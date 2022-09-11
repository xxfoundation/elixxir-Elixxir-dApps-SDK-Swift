import ComposableArchitecture
import XCTestDynamicOverlay
import XXClient

public struct VerifyContactState: Equatable {
  public init(
    xxContact: XXClient.Contact
  ) {
    self.xxContact = xxContact
  }

  public var xxContact: XXClient.Contact
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
