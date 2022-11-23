import XXClient
import XCTestDynamicOverlay

public struct MessengerLogIn {
  public enum Error: Swift.Error, Equatable {
    case notLoaded
    case notConnected
  }

  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension MessengerLogIn {
  public static func live(_ env: MessengerEnvironment) -> MessengerLogIn {
    MessengerLogIn {
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
          environment: env.udEnvironment ?? (try e2e.getUdEnvironmentFromNdf())
        ),
        follower: .init {
          cMix.networkFollowerStatus()
        }
      ))
    }
  }
}

extension MessengerLogIn {
  public static let unimplemented = MessengerLogIn(
    run: XCTUnimplemented("\(Self.self)")
  )
}
