import SwiftUI

struct ShakeViewModifier: ViewModifier {
  var action: () -> Void

  func body(content: Content) -> some View {
    content.onReceive(
      NotificationCenter.default.publisher(
        for: UIDevice.deviceDidShakeNotification
      ),
      perform: { _ in
        action()
      }
    )
  }
}

extension View {
  public func onShake(perform action: @escaping () -> Void) -> some View {
    modifier(ShakeViewModifier(action: action))
  }
}

extension UIDevice {
  static let deviceDidShakeNotification = Notification.Name(
    rawValue: "deviceDidShakeNotification"
  )
}

extension UIWindow {
  open override func motionEnded(
    _ motion: UIEvent.EventSubtype,
    with event: UIEvent?
  ) {
    super.motionEnded(motion, with: event)
    guard motion == .motionShake else { return }
    NotificationCenter.default.post(
      name: UIDevice.deviceDidShakeNotification,
      object: nil
    )
  }
}
