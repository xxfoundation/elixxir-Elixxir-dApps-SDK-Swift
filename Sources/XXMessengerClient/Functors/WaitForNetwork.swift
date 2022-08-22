import XXClient
import XCTestDynamicOverlay

public struct WaitForNetwork {
  public enum Error: Swift.Error {
    case notLoaded
    case timeout
  }

  public var run: (Int) throws -> Void

  public func callAsFunction(
    timeoutMS: Int = 30_000
  ) throws {
    try run(timeoutMS)
  }
}

extension WaitForNetwork {
  public static func live(_ env: Environment) -> WaitForNetwork {
    WaitForNetwork { timeoutMS in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      guard cMix.waitForNetwork(timeoutMS: timeoutMS) else {
        throw Error.timeout
      }
    }
  }
}

extension WaitForNetwork {
  public static let unimplemented = WaitForNetwork(
    run: XCTUnimplemented("\(Self.self)")
  )
}
