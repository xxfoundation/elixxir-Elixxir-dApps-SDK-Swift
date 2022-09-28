import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerStop {
  public struct Wait: Equatable {
    public init(
      sleepInterval: TimeInterval = 1,
      retries: Int = 10
    ) {
      self.sleepInterval = sleepInterval
      self.retries = retries
    }

    public var sleepInterval: TimeInterval
    public var retries: Int
  }

  public enum Error: Swift.Error {
    case notLoaded
    case timedOut
  }

  public var run: (Wait?) throws -> Void

  public func callAsFunction(wait: Wait? = nil) throws -> Void {
    try run(wait)
  }
}

extension MessengerStop {
  public static func live(_ env: MessengerEnvironment) -> MessengerStop {
    MessengerStop { wait in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      guard cMix.networkFollowerStatus() == .running else {
        return
      }
      try cMix.stopNetworkFollower()
      guard let wait else { return }
      var retries = wait.retries
      var hasRunningProcesses = cMix.hasRunningProcesses()
      while retries > 0 && hasRunningProcesses {
        env.sleep(wait.sleepInterval)
        hasRunningProcesses = cMix.hasRunningProcesses()
        retries -= 1
      }
      if hasRunningProcesses {
        throw Error.timedOut
      }
    }
  }
}

extension MessengerStop {
  public static let unimplemented = MessengerStop(
    run: XCTUnimplemented("\(Self.self)")
  )
}
