import XCTestDynamicOverlay

public struct MessengerDestroy {
  public var run: () throws -> Void

  public func callAsFunction() throws -> Void {
    try run()
  }
}

extension MessengerDestroy {
  public static func live(_ env: MessengerEnvironment) -> MessengerDestroy {
    MessengerDestroy {
      try env.fileManager.removeDirectory(env.storageDir)
      env.ud.set(nil)
      env.e2e.set(nil)
      env.cMix.set(nil)
    }
  }
}

extension MessengerDestroy {
  public static let unimplemented = MessengerDestroy(
    run: XCTUnimplemented("\(Self.self)")
  )
}
