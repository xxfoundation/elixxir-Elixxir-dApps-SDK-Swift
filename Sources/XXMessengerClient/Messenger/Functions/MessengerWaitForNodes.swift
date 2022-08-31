import Foundation
import XXClient
import XCTestDynamicOverlay

public struct MessengerWaitForNodes {
  public typealias Progress = (NodeRegistrationReport) -> Void

  public enum Error: Swift.Error {
    case notLoaded
    case timeout
  }

  public var run: (Double, TimeInterval, Int, @escaping Progress) throws -> Void

  public func callAsFunction(
    targetRatio: Double = 0.8,
    sleepInterval: TimeInterval = 1,
    retries: Int = 10,
    onProgress: @escaping Progress = { _ in }
  ) throws {
    try run(targetRatio, sleepInterval, retries, onProgress)
  }
}

extension MessengerWaitForNodes {
  public static func live(_ env: MessengerEnvironment) -> MessengerWaitForNodes {
    MessengerWaitForNodes { targetRatio, sleepInterval, retries, onProgress in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }

      var report = try cMix.getNodeRegistrationStatus()
      var retries = retries
      onProgress(report)

      while report.ratio < targetRatio && retries > 0 {
        env.sleep(sleepInterval)
        report = try cMix.getNodeRegistrationStatus()
        retries -= 1
        onProgress(report)
      }

      if report.ratio < targetRatio {
        throw Error.timeout
      }
    }
  }
}

extension MessengerWaitForNodes {
  public static let unimplemented = MessengerWaitForNodes(
    run: XCTUnimplemented("\(Self.self)")
  )
}
