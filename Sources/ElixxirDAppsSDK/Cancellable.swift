public final class Cancellable {
  public init(cancel: @escaping () -> Void) {
    self.cancel = cancel
  }

  deinit {
    cancel()
  }

  public let cancel: () -> Void
}
