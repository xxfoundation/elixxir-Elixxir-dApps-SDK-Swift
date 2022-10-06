import XXClient
import XCTestDynamicOverlay

public struct MessengerRegister {
  public enum Error: Swift.Error, Equatable {
    case notLoaded
    case notConnected
  }

  public var run: (String) throws -> Void

  public func callAsFunction(
    username: String
  ) throws {
    try run(username)
  }
}

extension MessengerRegister {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegister {
    MessengerRegister { username in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      env.ud.set(try env.newOrLoadUd(
        params: .init(
          e2eId: e2e.getId(),
          username: username,
          registrationValidationSignature: cMix.getReceptionRegistrationValidationSignature(),
          environment: env.udEnvironment ?? (try e2e.getUdEnvironmentFromNdf())
        ),
        follower: .init {
          cMix.networkFollowerStatus()
        }
      ))
    }
  }
}

extension MessengerRegister {
  public static let unimplemented = MessengerRegister(
    run: XCTUnimplemented("\(Self.self)")
  )
}
