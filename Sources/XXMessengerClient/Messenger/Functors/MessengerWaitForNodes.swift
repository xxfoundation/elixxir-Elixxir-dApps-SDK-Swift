import XXClient
import XCTestDynamicOverlay

public struct MessengerWaitForNodes {
  public typealias Progress = (Double) -> Void

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

      func getProgress(_ report: NodeRegistrationReport) -> Double {
        min(1, ((report.ratio / targetRatio) * 100).rounded() / 100)
      }

      var report = try cMix.getNodeRegistrationStatus()
      var retries = retries
      onProgress(getProgress(report))

      while report.ratio < targetRatio && retries > 0 {
        env.sleep(sleepMS)
        retries -= 1
        report = try cMix.getNodeRegistrationStatus()
        onProgress(getProgress(report))
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
