import Bindings
import XCTestDynamicOverlay

public struct Processor {
  public struct Callback: Equatable {
    public init(message: Data, receptionId: Data, ephemeralId: Int64, roundId: Int64) {
      self.message = message
      self.receptionId = receptionId
      self.ephemeralId = ephemeralId
      self.roundId = roundId
    }

    public var message: Data
    public var receptionId: Data
    public var ephemeralId: Int64
    public var roundId: Int64
  }

  public init(serviceTag: String, process: @escaping (Callback) -> Void) {
    self.serviceTag = serviceTag
    self.process = process
  }

  public var serviceTag: String
  public var process: (Callback) -> Void
}

extension Processor {
  public static let unimplemented = Processor(
    serviceTag: "unimplemented",
    process: XCTUnimplemented("\(Self.self).process")
  )
}

extension Processor {
  func makeBindingsProcessor() -> BindingsProcessorProtocol {
    class CallbackObject: NSObject, BindingsProcessorProtocol {
      init(_ callback: Processor) {
        self.callback = callback
      }

      let callback: Processor

      func process(_ message: Data?, receptionId: Data?, ephemeralId: Int64, roundId: Int64) {
        guard let message = message else {
          fatalError("BindingsProcessor.process received `nil` message")
        }
        guard let receptionId = receptionId else {
          fatalError("BindingsProcessor.process received `nil` receptionId")
        }
        callback.process(Callback(
          message: message,
          receptionId: receptionId,
          ephemeralId: ephemeralId,
          roundId: roundId
        ))
      }

      func string() -> String {
        callback.serviceTag
      }
    }

    return CallbackObject(self)
  }
}
