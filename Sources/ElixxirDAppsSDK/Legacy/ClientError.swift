public struct ClientError: Error, Equatable {
  public init(source: String, message: String, trace: String) {
    self.source = source
    self.message = message
    self.trace = trace
  }

  public var source: String
  public var message: String
  public var trace: String
}
