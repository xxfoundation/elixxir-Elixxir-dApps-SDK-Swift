import XXClient
import XCTestDynamicOverlay

public struct IsConnected {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension IsConnected {
  public static func live(_ env: Environment) -> IsConnected {
    IsConnected {
      env.e2e() != nil
    }
  }
}

extension IsConnected {
  public static let unimplemented = IsConnected(
    run: XCTUnimplemented()
  )
}

