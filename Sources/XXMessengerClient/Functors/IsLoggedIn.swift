import XXClient
import XCTestDynamicOverlay

public struct IsLoggedIn {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension IsLoggedIn {
  public static func live(_ env: Environment) -> IsLoggedIn {
    IsLoggedIn {
      env.ud() != nil
    }
  }
}

extension IsLoggedIn {
  public static let unimplemented = IsLoggedIn(
    run: XCTUnimplemented()
  )
}
