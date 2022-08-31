import Bindings
import XCTestDynamicOverlay

public struct ConnectionGetPartner {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension ConnectionGetPartner {
  public static func live(_ bindingsConnection: BindingsConnection) -> ConnectionGetPartner {
    ConnectionGetPartner {
      guard let data = bindingsConnection.getPartner() else {
        fatalError("BindingsConnection.getPartner returned `nil`")
      }
      return data
    }
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> ConnectionGetPartner {
    ConnectionGetPartner {
      guard let data = bindingsConnection.getPartner() else {
        fatalError("BindingsAuthenticatedConnection.getPartner returned `nil`")
      }
      return data
    }
  }
}

extension ConnectionGetPartner {
  public static let unimplemented = ConnectionGetPartner(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
