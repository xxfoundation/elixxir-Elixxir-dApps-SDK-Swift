import ComposableArchitecture
import XCTestDynamicOverlay

public struct ErrorState: Equatable {
  public init(error: NSError) {
    self.error = error
  }

  public var error: NSError
}

public enum ErrorAction: Equatable {}

public struct ErrorEnvironment {
  public init() {}
}

public let errorReducer = Reducer<ErrorState, ErrorAction, ErrorEnvironment>.empty

extension ErrorEnvironment {
  public static let unimplemented = ErrorEnvironment()
}
