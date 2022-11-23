import Bindings
import XCTestDynamicOverlay

public struct SetDashboardURL {
  public var run: (String) -> Void

  public func callAsFunction(baseURL: String) {
    run(baseURL)
  }
}

extension SetDashboardURL {
  public static let live = SetDashboardURL { baseURL in
    BindingsSetDashboardURL(baseURL)
  }
}

extension SetDashboardURL {
  public static let unimplemented = SetDashboardURL(
    run: XCTUnimplemented("\(Self.self)")
  )
}
