import SwiftUI

public struct AppVersionText: View {
  public init() {}

  public var body: some View {
    Text("v\(version) (\(build))")
  }

  var version: String = Bundle.main.shortVersionString ?? "0.0.0"
  var build: String = Bundle.main.versionString ?? "0"
}

private extension Bundle {
  var shortVersionString: String? {
    infoDictionary?["CFBundleShortVersionString"] as? String
  }
  var versionString: String? {
    infoDictionary?["CFBundleVersion"] as? String
  }
}

#if DEBUG
struct AppVersionText_Previews: PreviewProvider {
  static var previews: some View {
    AppVersionText()
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
#endif
