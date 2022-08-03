import Bindings

public struct Cmix {
  public var getId: CmixGetId
  public var getReceptionRegistrationValidationSignature: CmixGetReceptionRegistrationValidationSignature
  public var makeReceptionIdentity: CmixMakeReceptionIdentity
  public var makeLegacyReceptionIdentity: CmixMakeLegacyReceptionIdentity
  public var isHealthy: CmixIsHealthy
  public var hasRunningProcesses: CmixHasRunningProcesses
  public var networkFollowerStatus: CmixNetworkFollowerStatus
  public var startNetworkFollower: CmixStartNetworkFollower
  public var stopNetworkFollower: CmixStopNetworkFollower
  public var waitForNetwork: CmixWaitForNetwork
  public var registerClientErrorCallback: CmixRegisterClientErrorCallback
  public var addHealthCallback: CmixAddHealthCallback
  public var waitForMessageDelivery: CmixWaitForMessageDelivery
  public var connect: CmixConnect
}

extension Cmix {
  public static func live(_ bindingsCmix: BindingsCmix) -> Cmix {
    Cmix(
      getId: .live(bindingsCmix),
      getReceptionRegistrationValidationSignature: .live(bindingsCmix),
      makeReceptionIdentity: .live(bindingsCmix),
      makeLegacyReceptionIdentity: .live(bindingsCmix),
      isHealthy: .live(bindingsCmix),
      hasRunningProcesses: .live(bindingsCmix),
      networkFollowerStatus: .live(bindingsCmix),
      startNetworkFollower: .live(bindingsCmix),
      stopNetworkFollower: .live(bindingsCmix),
      waitForNetwork: .live(bindingsCmix),
      registerClientErrorCallback: .live(bindingsCmix),
      addHealthCallback: .live(bindingsCmix),
      waitForMessageDelivery: .live(bindingsCmix),
      connect: .live(bindingsCmix)
    )
  }
}

extension Cmix {
  public static let unimplemented = Cmix(
    getId: .unimplemented,
    getReceptionRegistrationValidationSignature: .unimplemented,
    makeReceptionIdentity: .unimplemented,
    makeLegacyReceptionIdentity: .unimplemented,
    isHealthy: .unimplemented,
    hasRunningProcesses: .unimplemented,
    networkFollowerStatus: .unimplemented,
    startNetworkFollower: .unimplemented,
    stopNetworkFollower: .unimplemented,
    waitForNetwork: .unimplemented,
    registerClientErrorCallback: .unimplemented,
    addHealthCallback: .unimplemented,
    waitForMessageDelivery: .unimplemented,
    connect: .unimplemented
  )
}
