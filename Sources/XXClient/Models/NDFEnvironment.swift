import Foundation

public struct NDFEnvironment: Equatable {
  public init(url: URL, cert: String) {
    self.url = url
    self.cert = cert
  }

  public var url: URL
  public var cert: String
}

extension NDFEnvironment {
  public static let mainnet = NDFEnvironment(
    url: URL(string: "https://elixxir-bins.s3.us-west-1.amazonaws.com/ndf/mainnet.json")!,
    cert: """
      -----BEGIN CERTIFICATE-----
      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
      UGb8k8vh6tzqYZAOKg==
      -----END CERTIFICATE-----
      """
  )
}

extension NDFEnvironment {
  public static let unimplemented = NDFEnvironment(
    url: URL(fileURLWithPath: "unimplemented"),
    cert: "unimplemented"
  )
}
