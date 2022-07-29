import Bindings
import XCTestDynamicOverlay

public struct LoadCmix {
  public var run: (String, Data, Data) throws -> Cmix

  public func callAsFunction(
    storageDir: String,
    password: Data,
    cmixParamsJSON: Data
  ) throws -> Cmix {
    try run(storageDir, password, cmixParamsJSON)
  }
}

extension LoadCmix {
  public static let live = LoadCmix { storageDir, password, cmixParamsJSON in
    var error: NSError?
    let bindingsCmix = BindingsLoadCmix(storageDir, password, cmixParamsJSON, &error)
    if let error = error {
      throw error
    }
    guard let bindingsCmix = bindingsCmix else {
      fatalError("BindingsLoadCmix returned `nil` without providing error")
    }
    return Cmix.live(bindingsCmix)
  }
}

extension LoadCmix {
  public static let unimplemented = LoadCmix(
    run: XCTUnimplemented("\(Self.self)")
  )
}
