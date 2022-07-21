import Bindings

public struct Cmix {
  public var getId: CmixGetId
  public var makeReceptionIdentity: MakeReceptionIdentity
  public var isHealthy: CmixIsHealthy
  public var hasRunningProcesses: CmixHasRunningProcesses
}

extension Cmix {
  public static func live(_ bindingsCmix: BindingsCmix) -> Cmix {
    Cmix(
      getId: .live(bindingsCmix),
      makeReceptionIdentity: .live(bindingsCmix),
      isHealthy: .live(bindingsCmix)
    )
  }
}

extension Cmix {
  public static let unimplemented = Cmix(
    getId: .unimplemented,
    makeReceptionIdentity: .unimplemented,
    isHealthy: .unimplemented
  )
}
