import XXClient
import XCTestDynamicOverlay

public struct IsLoaded {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension IsLoaded {
  public static func live(_ env: Environment) -> IsLoaded {
    IsLoaded {
      env.cMix() != nil
    }
  }
}

extension IsLoaded {
  public static let unimplemented = IsLoaded(
    run: XCTUnimplemented()
  )
}
