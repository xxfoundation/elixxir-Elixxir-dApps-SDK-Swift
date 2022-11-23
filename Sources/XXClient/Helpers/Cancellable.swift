public final class Cancellable {
  public init(cancel: @escaping () -> Void) {
    self.onCancel = cancel
  }

  deinit {
    cancel()
  }

  public func cancel() {
    guard isCancelled == false else { return }
    isCancelled = true
    onCancel()
  }

  private var isCancelled = false
  private let onCancel: () -> Void
}
