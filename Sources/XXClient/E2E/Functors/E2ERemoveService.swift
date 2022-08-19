import Bindings
import XCTestDynamicOverlay

public struct E2ERemoveService {
  public var run: (String) throws -> Void

  public func callAsFunction(tag: String) throws {
    try run(tag)
  }
}

extension E2ERemoveService {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ERemoveService {
    E2ERemoveService(run: bindingsE2E.removeService(_:))
  }
}

extension E2ERemoveService {
  public static let unimplemented = E2ERemoveService(
    run: XCTUnimplemented("\(Self.self)")
  )
}
