import Bindings
import XCTestDynamicOverlay

public struct TransmitSingleUse {
  public struct Params: Equatable {
    public init(
      e2eId: Int,
      recipient: Contact,
      tag: String,
      payload: Data,
      paramsJSON: Data
    ) {
      self.e2eId = e2eId
      self.recipient = recipient
      self.tag = tag
      self.payload = payload
      self.paramsJSON = paramsJSON
    }

    public var e2eId: Int
    public var recipient: Contact
    public var tag: String
    public var payload: Data
    public var paramsJSON: Data
  }

  public var run: (Params, SingleUseResponse) throws -> SingleUseSendReport

  public func callAsFunction(
    params: Params,
    callback: SingleUseResponse
  ) throws -> SingleUseSendReport {
    try run(params, callback)
  }
}

extension TransmitSingleUse {
  public static let live = TransmitSingleUse { params, callback in
    var error: NSError?
    let reportData = BindingsTransmitSingleUse(
      params.e2eId,
      params.recipient.data,
      params.tag,
      params.payload,
      params.paramsJSON,
      callback.makeBindingsSingleUseResponse(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let reportData = reportData else {
      fatalError("BindingsTransmitSingleUse returned `nil` without providing error")
    }
    return try SingleUseSendReport.decode(reportData)
  }
}

extension TransmitSingleUse {
  public static let unimplemented = TransmitSingleUse(
    run: XCTUnimplemented("\(Self.self)")
  )
}
