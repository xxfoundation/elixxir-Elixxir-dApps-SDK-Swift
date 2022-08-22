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
      guard let cMix = env.ctx.getCMix() else {
        throw Error.notLoaded
      }
      guard let e2e = env.ctx.getE2E() else {
        throw Error.notConnected
      }
      if cMix.networkFollowerStatus() != .running {
        try cMix.startNetworkFollower(timeoutMS: 30_000)
      }
      env.ctx.setUD(try env.newOrLoadUd(
        params: .init(
          e2eId: e2e.getId(),
          username: username,
          registrationValidationSignature: cMix.getReceptionRegistrationValidationSignature(),
          cert: env.udCert ?? e2e.getUdCertFromNdf(),
          contactFile: env.udContact ?? (try e2e.getUdContactFromNdf()),
          address: env.udAddress ?? e2e.getUdAddressFromNdf()
        ),
        follower: .init {
          cMix.networkFollowerStatus().rawValue
        }
      ))
    }
  }
}

extension MessengerRegister {
  public static let unimplemented = MessengerRegister(
    run: XCTUnimplemented()
  )
}
