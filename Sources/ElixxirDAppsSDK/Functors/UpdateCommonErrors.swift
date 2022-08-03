import Bindings
import XCTestDynamicOverlay

public struct UpdateCommonErrors {
  public var run: (String) throws -> Void

  public func callAsFunction(jsonFile: String) throws {
    try run(jsonFile)
  }
}

extension UpdateCommonErrors {
  public static let live = UpdateCommonErrors { jsonFile in
    var error: NSError?
    let result = BindingsUpdateCommonErrors(
      jsonFile,
      &error
    )
    if let error = error {
      throw error
    }
    guard result else {
      fatalError("BindingsUpdateCommonErrors returned `false` without providing error")
    }
  }
}

extension UpdateCommonErrors {
  public static let unimplemented = UpdateCommonErrors(
    run: XCTUnimplemented("\(Self.self)")
  )
}
