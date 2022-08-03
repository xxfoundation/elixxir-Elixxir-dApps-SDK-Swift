import XCTestDynamicOverlay

public struct CMixManagerLoad {
  public var run: () throws -> CMix

  public func callAsFunction() throws -> CMix {
    try run()
  }
}

extension CMixManagerLoad {
  public static func live(
    directoryPath: String,
    passwordStorage: PasswordStorage,
    getCMixParams: GetCMixParams,
    loadCMix: LoadCMix
  ) -> CMixManagerLoad {
    CMixManagerLoad {
      try loadCMix(
        storageDir: directoryPath,
        password: passwordStorage.load(),
        cMixParamsJSON: getCMixParams()
      )
    }
  }
}

extension CMixManagerLoad {
  public static let unimplemented = CMixManagerLoad(
    run: XCTUnimplemented("\(Self.self)")
  )
}
