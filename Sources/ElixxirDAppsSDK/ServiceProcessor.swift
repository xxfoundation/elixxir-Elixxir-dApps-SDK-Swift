import Bindings
import XCTestDynamicOverlay

public struct ServiceProcessor {
  public typealias Process = (
    _ message: Data,
    _ receptionId: Data,
    _ ephemeralId: Int64,
    _ roundId: Int64
  ) -> Void

  public init(serviceTag: String, process: @escaping Process) {
    self.serviceTag = serviceTag
    self.process = process
  }

  public var serviceTag: String
  public var process: Process
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
        serviceProcessor.process(message, receptionId, ephemeralId, roundId)
      }

      func string() -> String {
        serviceProcessor.serviceTag
      }
    }

    return Processor(self)
  }
}
