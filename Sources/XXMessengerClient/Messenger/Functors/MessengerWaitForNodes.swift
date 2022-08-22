import XXClient
import XCTestDynamicOverlay

public struct MessengerWaitForNodes {
  public typealias Progress = (NodeRegistrationReport) -> Void

  public enum Error: Swift.Error {
    case notLoaded
    case timeout
  }

  public var run: (Double, Int, Int, @escaping Progress) throws -> Void

  public func callAsFunction(
    targetRatio: Double = 0.8,
    sleepMS: Int = 1_000,
    retries: Int = 10,
    onProgress: @escaping Progress = { _ in }
  ) throws {
    try run(targetRatio, sleepMS, retries, onProgress)
  }
}

extension MessengerWaitForNodes {
  public static func live(_ env: MessengerEnvironment) -> MessengerWaitForNodes {
    MessengerWaitForNodes { targetRatio, sleepMS, retries, onProgress in
      guard let cMix = env.ctx.getCMix() else {
        throw Error.notLoaded
      }

      var report = try cMix.getNodeRegistrationStatus()
      var retries = retries
      onProgress(report)

      while report.ratio < targetRatio && retries > 0 {
        env.sleep(sleepMS)
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
