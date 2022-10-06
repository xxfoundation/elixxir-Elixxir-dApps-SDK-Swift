import Bindings

public struct E2E {
  public var getId: E2EGetId
  public var getReceptionId: E2EGetReceptionId
  public var getHistoricalDHPrivateKey: E2EGetHistoricalDHPrivateKey
  public var getHistoricalDHPublicKey: E2EGetHistoricalDHPublicKey
  public var getContact: E2EGetContact
  public var getAllPartnerIds: E2EGetAllPartnerIds
  public var getUdAddressFromNdf: E2EGetUdAddressFromNdf
  public var getUdCertFromNdf: E2EGetUdCertFromNdf
  public var getUdContactFromNdf: E2EGetUdContactFromNdf
  public var getUdEnvironmentFromNdf: E2EGetUdEnvironmentFromNdf
  public var payloadSize: E2EPayloadSize
  public var partitionSize: E2EPartitionSize
  public var addPartnerCallback: E2EAddPartnerCallback
  public var addService: E2EAddService
  public var removeService: E2ERemoveService
  public var hasAuthenticatedChannel: E2EHasAuthenticatedChannel
  public var requestAuthenticatedChannel: E2ERequestAuthenticatedChannel
  public var resetAuthenticatedChannel: E2EResetAuthenticatedChannel
  public var callAllReceivedRequests: E2ECallAllReceivedRequests
  public var getReceivedRequest: E2EGetReceivedRequest
  public var deleteRequest: E2EDeleteRequest
  public var verifyOwnership: E2EVerifyOwnership
  public var confirmReceivedRequest: E2EConfirmReceivedRequest
  public var replayConfirmReceivedRequest: E2EReplayConfirmReceivedRequest
  public var send: E2ESend
  public var registerListener: E2ERegisterListener
}

extension E2E {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2E {
    E2E(
      getId: .live(bindingsE2E),
      getReceptionId: .live(bindingsE2E),
      getHistoricalDHPrivateKey: .live(bindingsE2E),
      getHistoricalDHPublicKey: .live(bindingsE2E),
      getContact: .live(bindingsE2E),
      getAllPartnerIds: .live(bindingsE2E),
      getUdAddressFromNdf: .live(bindingsE2E),
      getUdCertFromNdf: .live(bindingsE2E),
      getUdContactFromNdf: .live(bindingsE2E),
      getUdEnvironmentFromNdf: .live(bindingsE2E),
      payloadSize: .live(bindingsE2E),
      partitionSize: .live(bindingsE2E),
      addPartnerCallback: .live(bindingsE2E),
      addService: .live(bindingsE2E),
      removeService: .live(bindingsE2E),
      hasAuthenticatedChannel: .live(bindingsE2E),
      requestAuthenticatedChannel: .live(bindingsE2E),
      resetAuthenticatedChannel: .live(bindingsE2E),
      callAllReceivedRequests: .live(bindingsE2E),
      getReceivedRequest: .live(bindingsE2E),
      deleteRequest: .live(bindingsE2E),
      verifyOwnership: .live(bindingsE2E),
      confirmReceivedRequest: .live(bindingsE2E),
      replayConfirmReceivedRequest: .live(bindingsE2E),
      send: .live(bindingsE2E),
      registerListener: .live(bindingsE2E)
    )
  }
}

extension E2E {
  public static let unimplemented = E2E(
    getId: .unimplemented,
    getReceptionId: .unimplemented,
    getHistoricalDHPrivateKey: .unimplemented,
    getHistoricalDHPublicKey: .unimplemented,
    getContact: .unimplemented,
    getAllPartnerIds: .unimplemented,
    getUdAddressFromNdf: .unimplemented,
    getUdCertFromNdf: .unimplemented,
    getUdContactFromNdf: .unimplemented,
    getUdEnvironmentFromNdf: .unimplemented,
    payloadSize: .unimplemented,
    partitionSize: .unimplemented,
    addPartnerCallback: .unimplemented,
    addService: .unimplemented,
    removeService: .unimplemented,
    hasAuthenticatedChannel: .unimplemented,
    requestAuthenticatedChannel: .unimplemented,
    resetAuthenticatedChannel: .unimplemented,
    callAllReceivedRequests: .unimplemented,
    getReceivedRequest: .unimplemented,
    deleteRequest: .unimplemented,
    verifyOwnership: .unimplemented,
    confirmReceivedRequest: .unimplemented,
    replayConfirmReceivedRequest: .unimplemented,
    send: .unimplemented,
    registerListener: .unimplemented
  )
}
