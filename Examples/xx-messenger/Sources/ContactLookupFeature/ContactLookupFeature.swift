import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

public struct ContactLookupState: Equatable {
  public init(
    id: Data,
    isLookingUp: Bool = false
  ) {
    self.id = id
    self.isLookingUp = isLookingUp
  }

  public var id: Data
  public var isLookingUp: Bool
}

public enum ContactLookupAction: Equatable {
  case task
  case cancelTask
  case lookupTapped
}

public struct ContactLookupEnvironment {
  public init() {}
}

#if DEBUG
extension ContactLookupEnvironment {
  public static let unimplemented = ContactLookupEnvironment()
}
#endif

public let contactLookupReducer = Reducer<ContactLookupState, ContactLookupAction, ContactLookupEnvironment>
{ state, action, env in
  switch action {
  case .task:
    return .none

  case .cancelTask:
    return .none

  case .lookupTapped:
    return .none
  }
}
