import Bindings

public struct NDFDownloader {
  public var run: (Environment) throws -> Data

  public func callAsFunction(_ env: Environment) throws -> Data {
    try run(env)
  }
}

extension NDFDownloader {
  public static let live = NDFDownloader { env in
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

#if DEBUG
extension NDFDownloader {
  public static let failing = NDFDownloader { _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
