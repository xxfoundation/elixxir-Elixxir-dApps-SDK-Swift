import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerReceiveFile {
  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: () throws -> Void

  public func callAsFunction() throws -> Void {
    try run()
  }
}

extension MessengerReceiveFile {
  public static func live(_ env: MessengerEnvironment) -> MessengerReceiveFile {
    MessengerReceiveFile {
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      // TODO: implement receiving file
    }
  }
}

extension MessengerReceiveFile {
  public static let unimplemented = MessengerReceiveFile(
    run: XCTUnimplemented("\(Self.self)")
  )
}
