import SwiftUI

struct NetworkHealthStatusView: View {
  var status: Bool?

  var body: some View {
    switch status {
    case .some(true):
      Label("Healthy", systemImage: "wifi")
        .foregroundColor(.green)

    case .some(false):
      Label("Unhealthy", systemImage: "bolt.horizontal.fill")
        .foregroundColor(.red)

    case .none:
      Label("Unknown", systemImage: "questionmark")
    }
  }
}

#if DEBUG
struct NetworkHealthStatusView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NetworkHealthStatusView(status: true)
      NetworkHealthStatusView(status: false)
      NetworkHealthStatusView(status: nil)
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
