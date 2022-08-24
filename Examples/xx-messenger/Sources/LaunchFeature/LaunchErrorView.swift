import ComposableArchitecture
import SwiftUI

struct LaunchErrorView: View {
  var failure: String
  var onRetry: () -> Void

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        ScrollView {
          Text(failure)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }

        Divider()

        Button {
          onRetry()
        } label: {
          Text("Retry")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
      .navigationTitle("Error")
    }
    .navigationViewStyle(.stack)
  }
}

#if DEBUG
struct LaunchErrorView_Previews: PreviewProvider {
  static var previews: some View {
    LaunchErrorView(
      failure: "Something went wrong...",
      onRetry: {}
    )
  }
}
#endif
