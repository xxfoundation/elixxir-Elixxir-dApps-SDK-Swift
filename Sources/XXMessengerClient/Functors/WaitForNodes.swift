import XXClient
import XCTestDynamicOverlay

public struct WaitForNodes {
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

extension WaitForNodes {
  public static func live(_ env: Environment) -> WaitForNodes {
    WaitForNodes { targetRatio, sleepMS, retries, onProgress in
      guard let cMix = env.cMix() else {
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

extension WaitForNodes {
  public static let unimplemented = WaitForNodes(
    run: XCTUnimplemented("\(Self.self)")
  )
}
