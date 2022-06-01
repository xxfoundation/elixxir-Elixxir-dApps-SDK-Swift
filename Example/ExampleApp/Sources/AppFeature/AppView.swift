import SwiftUI

struct AppView: View {
  var body: some View {
    Text("AppView")
      .padding()
  }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}
#endif
