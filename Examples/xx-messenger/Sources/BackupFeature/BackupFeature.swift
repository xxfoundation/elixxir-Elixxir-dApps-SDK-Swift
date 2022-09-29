import ComposableArchitecture
import XCTestDynamicOverlay

public struct BackupState: Equatable {
  public init() {}
}

public enum BackupAction: Equatable {
  case start
}

public struct BackupEnvironment {
  public init() {}
}

#if DEBUG
extension BackupEnvironment {
  public static let unimplemented = BackupEnvironment()
}
#endif

public let backupReducer = Reducer<BackupState, BackupAction, BackupEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
