import XXClient
import XCTestDynamicOverlay

public struct IsRegistered {
  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: () throws -> Bool

  public func callAsFunction() throws -> Bool {
    try run()
  }
}

extension IsRegistered {
  public static func live(_ env: Environment) -> IsRegistered {
    IsRegistered {
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      return try env.isRegisteredWithUD(e2eId: e2e.getId())
    }
  }
}

extension IsRegistered {
  public static let unimplemented = IsRegistered(
    run: XCTUnimplemented()
  )
}
