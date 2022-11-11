import XXClient
import XCTestDynamicOverlay

public struct MessengerWaitForNetwork {
  public enum Error: Swift.Error, Equatable {
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

extension MessengerWaitForNetwork {
  public static func live(_ env: MessengerEnvironment) -> MessengerWaitForNetwork {
    MessengerWaitForNetwork { timeoutMS in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      guard cMix.waitForNetwork(timeoutMS: timeoutMS) else {
        throw Error.timeout
      }
    }
  }
}

extension MessengerWaitForNetwork {
  public static let unimplemented = MessengerWaitForNetwork(
    run: XCTUnimplemented("\(Self.self)")
  )
}
