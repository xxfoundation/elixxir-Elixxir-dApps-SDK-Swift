import Bindings
import XCTestDynamicOverlay

public struct ServiceProcessor {
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

extension ServiceProcessor {
  public static let unimplemented = ServiceProcessor(
    serviceTag: "unimplemented",
    process: XCTUnimplemented("\(Self.self).process")
  )
}

extension ServiceProcessor {
  func makeBindingsProcessor() -> BindingsProcessorProtocol {
    class Processor: NSObject, BindingsProcessorProtocol {
      init(_ serviceProcessor: ServiceProcessor) {
        self.serviceProcessor = serviceProcessor
      }

      let serviceProcessor: ServiceProcessor

      func process(_ message: Data?, receptionId: Data?, ephemeralId: Int64, roundId: Int64) {
        guard let message = message else {
          fatalError("BindingsProcessor.process received `nil` message")
        }
        guard let receptionId = receptionId else {
          fatalError("BindingsProcessor.process received `nil` receptionId")
        }
        serviceProcessor.process(Callback(
          message: message,
          receptionId: receptionId,
          ephemeralId: ephemeralId,
          roundId: roundId
        ))
      }

      func string() -> String {
        serviceProcessor.serviceTag
      }
    }

    return Processor(self)
  }
}
