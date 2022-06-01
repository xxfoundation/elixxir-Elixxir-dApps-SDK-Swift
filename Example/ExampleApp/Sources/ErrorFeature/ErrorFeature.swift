import ComposableArchitecture
import SwiftUI

public struct ErrorState: Equatable {
  public init(error: NSError) {
    self.error = error
  }

  var error: NSError
}

public enum ErrorAction: Equatable {}

public struct ErrorEnvironment {
  public init() {}
}

public let errorReducer = Reducer<ErrorState, ErrorAction, ErrorEnvironment>.empty

#if DEBUG
extension ErrorEnvironment {
  public static let failing = ErrorEnvironment()
}
#endif
