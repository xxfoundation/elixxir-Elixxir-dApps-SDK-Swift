public enum FilePartStatus: Equatable {
  case partDoesNotExist
  case unsent
  case arrived
  case received
  case unknown(code: Int)
}

extension FilePartStatus {
  public init(rawValue: Int) {
    switch rawValue {
    case let value where value < 0: self = .partDoesNotExist
    case 0: self = .unsent
    case 1: self = .arrived
    case 2: self = .received
    case let code: self = .unknown(code: code)
    }
  }
}
