import XXClient
import XCTestDynamicOverlay

public struct LogIn {
  public enum Error: Swift.Error, Equatable {
    case notLoaded
    case notConnected
  }

  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension LogIn {
  public static func live(_ env: Environment) -> LogIn {
    LogIn {
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      env.ud.set(try env.newOrLoadUd(
        params: .init(
          e2eId: e2e.getId(),
          username: nil,
          registrationValidationSignature: nil,
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

extension LogIn {
  public static let unimplemented = LogIn(
    run: XCTUnimplemented()
  )
}
