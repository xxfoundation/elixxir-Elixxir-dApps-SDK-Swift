import Bindings
import XCTestDynamicOverlay

public struct SearchUD {
  public struct Params: Equatable {
    public init(
      e2eId: Int,
      udContact: Contact,
      facts: [Fact],
      singleRequestParamsJSON: Data = GetSingleUseParams.liveDefault()
    ) {
      self.e2eId = e2eId
      self.udContact = udContact
      self.facts = facts
      self.singleRequestParamsJSON = singleRequestParamsJSON
    }

    public var e2eId: Int
    public var udContact: Contact
    public var facts: [Fact]
    public var singleRequestParamsJSON: Data
  }

  public var run: (Params, UdSearchCallback) throws -> SingleUseSendReport

  public func callAsFunction(
    params: Params,
    callback: UdSearchCallback
  ) throws -> SingleUseSendReport {
    try run(params, callback)
  }
}

extension SearchUD {
  public static let live = SearchUD { params, callback in
    var error: NSError?
    let reportData = BindingsSearchUD(
      params.e2eId,
      params.udContact.data,
      callback.makeBindingsUdSearchCallback(),
      try params.facts.encode(),
      params.singleRequestParamsJSON,
      &error
    )
    if let error = error {
      throw error
    }
    guard let reportData = reportData else {
      fatalError("BindingsSearchUD returned `nil` without providing error")
    }
    return try SingleUseSendReport.decode(reportData)
  }
}

extension SearchUD {
  public static let unimplemented = SearchUD(
    run: XCTUnimplemented("\(Self.self)")
  )
}

