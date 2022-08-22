import XXClient
import XCTestDynamicOverlay

public struct Register {
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

extension Register {
  public static func live(_ env: Environment) -> Register {
    Register { username in
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

extension Register {
  public static let unimplemented = Register(
    run: XCTUnimplemented()
  )
}
