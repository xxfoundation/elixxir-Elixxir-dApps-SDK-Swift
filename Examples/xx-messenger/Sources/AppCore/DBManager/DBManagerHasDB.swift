import XCTestDynamicOverlay

public struct DBManagerHasDB {
  init(run: @escaping () -> Bool) {
    self.run = run
  }

  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension DBManagerHasDB {
  public static let unimplemented = DBManagerHasDB(
    run: XCTUnimplemented("\(Self.self)")
  )
}
