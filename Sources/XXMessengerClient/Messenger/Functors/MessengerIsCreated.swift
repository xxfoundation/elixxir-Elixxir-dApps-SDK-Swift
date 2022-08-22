import XXClient
import XCTestDynamicOverlay

public struct MessengerIsCreated {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension MessengerIsCreated {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsCreated {
    MessengerIsCreated {
      env.fileManager.isDirectoryEmpty(env.storageDir) == false
    }
  }
}

extension MessengerIsCreated {
  public static let unimplemented = MessengerIsCreated(
    run: XCTUnimplemented()
  )
}
