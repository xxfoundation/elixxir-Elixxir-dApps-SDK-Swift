import XXClient

public class MessengerContext {
  public init(
    cMix: CMix? = nil,
    e2e: E2E? = nil,
    ud: UserDiscovery? = nil
  ) {
    self.cMix = cMix
    self.e2e = e2e
    self.ud = ud
  }

  public var cMix: CMix?
  public var e2e: E2E?
  public var ud: UserDiscovery?
}
