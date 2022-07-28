import Bindings
import XCTestDynamicOverlay

public struct E2EAddService {
  public var run: (Processor) throws -> Void

  public func callAsFunction(
    processor: Processor
  ) throws {
    try run(processor)
  }
}

extension E2EAddService {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EAddService {
    E2EAddService { processor in
      try bindingsE2E.addService(
        processor.serviceTag,
        processor: processor.makeBindingsProcessor()
      )
    }
  }
}

extension E2EAddService {
  public static let unimplemented = E2EAddService(
    run: XCTUnimplemented("\(Self.self)")
  )
}
