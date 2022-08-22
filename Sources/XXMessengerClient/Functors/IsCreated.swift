import XXClient
import XCTestDynamicOverlay

public struct IsCreated {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension IsCreated {
  public static func live(_ env: Environment) -> IsCreated {
    IsCreated {
      env.directoryManager.isEmpty(env.storageDir) == false
    }
  }
}

extension IsCreated {
  public static let unimplemented = IsCreated(
    run: XCTUnimplemented()
  )
}
