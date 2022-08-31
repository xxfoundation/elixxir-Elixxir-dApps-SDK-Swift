import Bindings
import XCTestDynamicOverlay

public struct CreateUserFriendlyErrorMessage {
  public var run: (String) -> String

  public func callAsFunction(_ errorString: String) -> String {
    run(errorString)
  }
}

extension CreateUserFriendlyErrorMessage {
  public static let live = CreateUserFriendlyErrorMessage { errorString in
    BindingsCreateUserFriendlyErrorMessage(errorString)
  }
}

extension CreateUserFriendlyErrorMessage {
  public static let unimplemented = CreateUserFriendlyErrorMessage(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented")
  )
}
