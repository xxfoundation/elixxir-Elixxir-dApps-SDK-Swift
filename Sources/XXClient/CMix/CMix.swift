import Bindings

public struct CMix {
  public var getId: CMixGetId
  public var getReceptionRegistrationValidationSignature: CMixGetReceptionRegistrationValidationSignature
  public var makeReceptionIdentity: CMixMakeReceptionIdentity
  public var isHealthy: CMixIsHealthy
  public var getNodeRegistrationStatus: CMixGetNodeRegistrationStatus
  public var changeNumberOfNodeRegistrations: CMixChangeNumberOfNodeRegistrations
  public var hasRunningProcesses: CMixHasRunningProcesses
  public var getRunningProcesses: CMixGetRunningProcesses
  public var networkFollowerStatus: CMixNetworkFollowerStatus
  public var startNetworkFollower: CMixStartNetworkFollower
  public var stopNetworkFollower: CMixStopNetworkFollower
  public var waitForNetwork: CMixWaitForNetwork
  public var registerClientErrorCallback: CMixRegisterClientErrorCallback
  public var addHealthCallback: CMixAddHealthCallback
  public var waitForRoundResult: CMixWaitForRoundResult
  public var connect: CMixConnect
}

extension CMix {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMix {
    CMix(
      getId: .live(bindingsCMix),
      getReceptionRegistrationValidationSignature: .live(bindingsCMix),
      makeReceptionIdentity: .live(bindingsCMix),
      isHealthy: .live(bindingsCMix),
      getNodeRegistrationStatus: .live(bindingsCMix),
      changeNumberOfNodeRegistrations: .live(bindingsCMix),
      hasRunningProcesses: .live(bindingsCMix),
      getRunningProcesses: .live(bindingsCMix),
      networkFollowerStatus: .live(bindingsCMix),
      startNetworkFollower: .live(bindingsCMix),
      stopNetworkFollower: .live(bindingsCMix),
      waitForNetwork: .live(bindingsCMix),
      registerClientErrorCallback: .live(bindingsCMix),
      addHealthCallback: .live(bindingsCMix),
      waitForRoundResult: .live(bindingsCMix),
      connect: .live(bindingsCMix)
    )
  }
}

extension CMix {
  public static let unimplemented = CMix(
    getId: .unimplemented,
    getReceptionRegistrationValidationSignature: .unimplemented,
    makeReceptionIdentity: .unimplemented,
    isHealthy: .unimplemented,
    getNodeRegistrationStatus: .unimplemented,
    changeNumberOfNodeRegistrations: .unimplemented,
    hasRunningProcesses: .unimplemented,
    getRunningProcesses: .unimplemented,
    networkFollowerStatus: .unimplemented,
    startNetworkFollower: .unimplemented,
    stopNetworkFollower: .unimplemented,
    waitForNetwork: .unimplemented,
    registerClientErrorCallback: .unimplemented,
    addHealthCallback: .unimplemented,
    waitForRoundResult: .unimplemented,
    connect: .unimplemented
  )
}
