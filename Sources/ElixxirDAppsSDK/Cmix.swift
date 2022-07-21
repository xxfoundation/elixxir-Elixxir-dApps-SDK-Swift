import Bindings

public struct Cmix {
  public var getId: CmixGetId
  public var makeReceptionIdentity: MakeReceptionIdentity
  public var isHealthy: CmixIsHealthy
  public var hasRunningProcesses: CmixHasRunningProcesses
  public var networkFollowerStatus: CmixNetworkFollowerStatus
  public var startNetworkFollower: CmixStartNetworkFollower
}

extension Cmix {
  public static func live(_ bindingsCmix: BindingsCmix) -> Cmix {
    Cmix(
      getId: .live(bindingsCmix),
      makeReceptionIdentity: .live(bindingsCmix),
      isHealthy: .live(bindingsCmix),
      hasRunningProcesses: .live(bindingsCmix),
      networkFollowerStatus: .live(bindingsCmix),
      startNetworkFollower: .live(bindingsCmix)
    )
  }
}

extension Cmix {
  public static let unimplemented = Cmix(
    getId: .unimplemented,
    makeReceptionIdentity: .unimplemented,
    isHealthy: .unimplemented,
    hasRunningProcesses: .unimplemented,
    networkFollowerStatus: .unimplemented,
    startNetworkFollower: .unimplemented
  )
}
