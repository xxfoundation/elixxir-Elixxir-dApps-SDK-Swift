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
      if let cMix = env.cMix() {
        if cMix.networkFollowerStatus() == .running {
          try cMix.stopNetworkFollower()
        }
        while cMix.hasRunningProcesses() {
          env.sleep(1)
        }
      }
      env.ud.set(nil)
      env.e2e.set(nil)
      env.cMix.set(nil)
      env.isListeningForMessages.set(false)
      try env.fileManager.removeItem(env.storageDir)
      try env.passwordStorage.remove()
    }
  }
}

extension MessengerDestroy {
  public static let unimplemented = MessengerDestroy(
    run: XCTUnimplemented("\(Self.self)")
  )
}
