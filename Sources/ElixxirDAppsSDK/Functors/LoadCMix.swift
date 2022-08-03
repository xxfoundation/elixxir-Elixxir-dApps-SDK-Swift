import Bindings
import XCTestDynamicOverlay

public struct LoadCMix {
  public var run: (String, Data, Data) throws -> CMix

  public func callAsFunction(
    storageDir: String,
    password: Data,
    cMixParamsJSON: Data = GetCMixParams.liveDefault()
  ) throws -> CMix {
    try run(storageDir, password, cMixParamsJSON)
  }
}

extension LoadCMix {
  public static let live = LoadCMix { storageDir, password, cMixParamsJSON in
    var error: NSError?
    let bindingsCMix = BindingsLoadCmix(storageDir, password, cMixParamsJSON, &error)
    if let error = error {
      throw error
    }
    guard let bindingsCMix = bindingsCMix else {
      fatalError("BindingsLoadCMix returned `nil` without providing error")
    }
    return CMix.live(bindingsCMix)
  }
}

extension LoadCMix {
  public static let unimplemented = LoadCMix(
    run: XCTUnimplemented("\(Self.self)")
  )
}
