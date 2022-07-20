import Bindings
import XCTestDynamicOverlay

public struct DownloadAndVerifySignedNdf {
  public var run: (Environment) throws -> Data

  public func callAsFunction(_ env: Environment) throws -> Data {
    try run(env)
  }
}

extension DownloadAndVerifySignedNdf {
  public static let live = DownloadAndVerifySignedNdf { env in
    var error: NSError?
    let data = BindingsDownloadAndVerifySignedNdfWithUrl(
      env.url.absoluteString,
      env.cert,
      &error
    )
    if let error = error {
      throw error
    }
    guard let data = data else {
      fatalError("BindingsDownloadAndVerifySignedNdfWithUrl returned `nil` without providing error")
    }
    return data
  }
}

extension DownloadAndVerifySignedNdf {
  public static let unimplemented = DownloadAndVerifySignedNdf(
    run: XCTUnimplemented("\(Self.self)")
  )
}
