import Foundation

public enum AuthCallback {
  case confirm(contact: Data, receptionId: Data, ephemeralId: Int64, roundId: Int64)
  case request(contact: Data, receptionId: Data, ephemeralId: Int64, roundId: Int64)
  case reset(contact: Data, receptionId: Data, ephemeralId: Int64, roundId: Int64)
}
