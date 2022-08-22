import XXClient
import XCTestDynamicOverlay

public struct Start {
  public enum Error: Swift.Error {
    case notLoaded
  }

  public var run: (Int) throws -> Void

  public func callAsFunction(
    timeoutMS: Int = 30_000
  ) throws {
    try run(timeoutMS)
  }
}

extension Start {
  public static func live(_ env: Environment) -> Start {
    Start { timeoutMS in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      guard cMix.networkFollowerStatus() != .running else {
        return
      }
      try cMix.startNetworkFollower(timeoutMS: timeoutMS)
    }
  }
}

extension Start {
  public static let unimplemented = Start(
    run: XCTUnimplemented("\(Self.self)")
  )
}
