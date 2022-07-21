public enum NetworkFollowerStatus: Equatable {
  case stopped
  case starting
  case running
  case stopping
  case unknown(code: Int)
}

extension NetworkFollowerStatus {
  public init(rawValue: Int) {
    switch rawValue {
    case 0: self = .stopped
    case 1_000: self = .starting
    case 2_000: self = .running
    case 3_000: self = .stopping
    case let code: self = .unknown(code: code)
    }
  }

  public var rawValue: Int {
    switch self {
    case .stopped: return 0
    case .starting: return 1_000
    case .running: return 2_000
    case .stopping: return 3_000
    case .unknown(let code): return code
    }
  }
}
