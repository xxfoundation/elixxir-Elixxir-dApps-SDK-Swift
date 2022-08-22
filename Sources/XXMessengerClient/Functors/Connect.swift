import XXClient
import XCTestDynamicOverlay

public struct Connect {
  public enum Error: Swift.Error, Equatable {
    case notLoaded
  }

  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension Connect {
  public static func live(_ env: Environment) -> Connect {
    Connect {
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      env.e2e.set(try env.login(
        cMixId: cMix.getId(),
        identity: try cMix.makeLegacyReceptionIdentity(),
        e2eParamsJSON: env.getE2EParams()
      ))
    }
  }
}

extension Connect {
  public static let unimplemented = Connect(
    run: XCTUnimplemented()
  )
}
