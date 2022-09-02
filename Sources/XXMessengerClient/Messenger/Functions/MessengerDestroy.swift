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
        var hasRunningProcesses = cMix.hasRunningProcesses()
        while hasRunningProcesses {
          env.sleep(1)
          hasRunningProcesses = cMix.hasRunningProcesses()
        }
      }
      env.ud.set(nil)
      env.e2e.set(nil)
      env.cMix.set(nil)
      try env.fileManager.removeDirectory(env.storageDir)
    }
  }
}

extension MessengerDestroy {
  public static let unimplemented = MessengerDestroy(
    run: XCTUnimplemented("\(Self.self)")
  )
}
