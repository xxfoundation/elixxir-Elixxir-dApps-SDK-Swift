import Bindings
import XCTestDynamicOverlay

public struct MultiLookupUD {
  public struct Params: Equatable {
    public init(
      e2eId: Int,
      udContact: Contact,
      lookupIds: [Data],
      singleRequestParams: Data = GetSingleUseParams.liveDefault()
    ) {
      self.e2eId = e2eId
      self.udContact = udContact
      self.lookupIds = lookupIds
      self.singleRequestParams = singleRequestParams
    }

    public var e2eId: Int
    public var udContact: Contact
    public var lookupIds: [Data]
    public var singleRequestParams: Data
  }

  public var run: (Params, UdMultiLookupCallback) throws -> Void

  public func callAsFunction(params: Params, callback: UdMultiLookupCallback) throws -> Void {
    try run(params, callback)
  }
}

extension MultiLookupUD {
  public static func live() -> MultiLookupUD {
    MultiLookupUD { params, callback in
      var error: NSError?
      let result = BindingsMultiLookupUD(
        params.e2eId,
        params.udContact.data,
        callback.makeBindingsUdMultiLookupCallback(),
        try JSONEncoder().encode(params.lookupIds),
        params.singleRequestParams,
        &error
      )
      if let error = error {
        throw error
      }
      guard result else {
        fatalError("BindingsMultiLookupUD returned `false` without providing error")
      }
    }
  }
}

extension MultiLookupUD {
  public static let unimplemented = MultiLookupUD(
    run: XCTUnimplemented("\(Self.self)")
  )
}
