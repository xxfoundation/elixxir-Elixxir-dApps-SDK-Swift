import ComposableArchitecture
import XCTestDynamicOverlay
import XXClient

public struct ResetAuthState: Equatable {
  public init(
    partner: Contact
  ) {
    self.partner = partner
  }

  var partner: Contact
}

public enum ResetAuthAction: Equatable {}

public struct ResetAuthEnvironment {
  public init() {}
}

#if DEBUG
extension ResetAuthEnvironment {
  public static let unimplemented = ResetAuthEnvironment()
}
#endif

public let resetAuthReducer = Reducer<ResetAuthState, ResetAuthAction, ResetAuthEnvironment>.empty
