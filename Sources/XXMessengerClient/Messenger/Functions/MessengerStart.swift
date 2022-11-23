import XXClient
import XCTestDynamicOverlay

public struct MessengerStart {
  public enum Error: Swift.Error, Equatable {
    case notLoaded
  }

  public var run: (Int) throws -> Void

  public func callAsFunction(
    timeoutMS: Int = 30_000
  ) throws {
    try run(timeoutMS)
  }
}

extension MessengerStart {
  public static func live(_ env: MessengerEnvironment) -> MessengerStart {
    MessengerStart { timeoutMS in
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

extension MessengerStart {
  public static let unimplemented = MessengerStart(
    run: XCTUnimplemented("\(Self.self)")
  )
}
