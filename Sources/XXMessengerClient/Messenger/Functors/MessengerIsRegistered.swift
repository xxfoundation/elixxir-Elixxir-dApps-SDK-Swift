import XXClient
import XCTestDynamicOverlay

public struct MessengerIsRegistered {
  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: () throws -> Bool

  public func callAsFunction() throws -> Bool {
    try run()
  }
}

extension MessengerIsRegistered {
  public static func live(_ env: MessengerEnvironment) -> MessengerIsRegistered {
    MessengerIsRegistered {
      guard let e2e = env.ctx.e2e else {
        throw Error.notConnected
      }
      return try env.isRegisteredWithUD(e2eId: e2e.getId())
    }
  }
}

extension MessengerIsRegistered {
  public static let unimplemented = MessengerIsRegistered(
    run: XCTUnimplemented()
  )
}
