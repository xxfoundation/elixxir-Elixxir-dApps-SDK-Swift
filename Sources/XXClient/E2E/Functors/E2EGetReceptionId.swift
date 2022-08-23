import Bindings
import XCTestDynamicOverlay

public struct E2EGetReceptionId {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension E2EGetReceptionId {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetReceptionId {
    E2EGetReceptionId {
      guard let data = bindingsE2E.getReceptionID() else {
        fatalError("BindingsE2e.getReceptionID returned `nil`")
      }
      return data
    }
  }
}

extension E2EGetReceptionId {
  public static let unimplemented = E2EGetReceptionId(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
