import Foundation

public struct RestlikeMessage: Equatable {
  public init(
    version: Int,
    headers: Data,
    content: Data,
    method: Int,
    uri: String,
    error: String
  ) {
    self.version = version
    self.headers = headers
    self.content = content
    self.method = method
    self.uri = uri
    self.error = error
  }

  public var version: Int
  public var headers: Data
  public var content: Data
  public var method: Int
  public var uri: String
  public var error: String
}

extension RestlikeMessage: Codable {
  enum CodingKeys: String, CodingKey {
    case version = "Version"
    case headers = "Headers"
    case content = "Content"
    case method = "Method"
    case uri = "URI"
    case error = "Error"
  }
}
