import ElixxirDAppsSDK
import SwiftUI

struct NetworkFollowerStatusView: View {
  var status: NetworkFollowerStatus?

  var body: some View {
    switch status {
    case .stopped:
      Label("Stopped", systemImage: "stop.fill")

    case .running:
      Label("Running", systemImage: "play.fill")

    case .stopping:
      Label("Stopping...", systemImage: "stop")

    case .unknown(let code):
      Label("Status \(code)", systemImage: "questionmark")

    case .none:
      Label("Unknown", systemImage: "questionmark")
    }
  }
}

#if DEBUG
struct NetworkFollowerStatusView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NetworkFollowerStatusView(status: .stopped)
      NetworkFollowerStatusView(status: .running)
      NetworkFollowerStatusView(status: .stopping)
      NetworkFollowerStatusView(status: .unknown(code: -1))
      NetworkFollowerStatusView(status: nil)
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
