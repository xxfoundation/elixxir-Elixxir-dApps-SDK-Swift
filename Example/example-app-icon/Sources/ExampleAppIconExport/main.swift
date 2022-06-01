import AppIconCreator
import ExampleAppIcon
import Foundation

extension URL {
  func deletingLastPathComponent() -> URL {
    var url = self
    url.deleteLastPathComponent()
    return url
  }
}

let exportURL = URL(fileURLWithPath: #file)
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .appendingPathComponent("ExampleApp (iOS)")
  .appendingPathComponent("Assets.xcassets")
  .appendingPathComponent("AppIcon.appiconset")

[IconImage]
  .images(for: ExampleAppIconView(), with: .iOS)
  .forEach { $0.save(to: exportURL) }
