import SwiftUI
import AppIconCreator

public struct ExampleAppIconView: View {
  public init() {}

  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Image(systemName: "cube.transparent")
          .resizable()
          .scaledToFit()
          .foregroundColor(.black.opacity(0.2))
          .padding(geometry.size.width * 0.1)
          .mask(
            ZStack {
              Rectangle()

              Image(systemName: "cube")
                .resizable()
                .scaledToFit()
                .blendMode(.destinationOut)
                .padding(geometry.size.width * 0.1)

              Circle()
                .blendMode(.destinationOut)
                .padding(geometry.size.width * 0.24)
            }
          )

        Circle()
          .fill(.black.opacity(0.3))
          .padding(geometry.size.width * 0.3)
          .mask {
            ZStack {
              Rectangle()
              Image(systemName: "cube")
                .resizable()
                .scaledToFit()
                .blendMode(.destinationOut)
                .padding(geometry.size.width * 0.1)
            }
          }

        Image(systemName: "cube")
          .resizable()
          .scaledToFit()
          .foregroundColor(.black.opacity(0.5))
          .padding(geometry.size.width * 0.1)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background {
        LinearGradient(
          gradient: Gradient(colors: [
            Color(cgColor: CGColor(red: 0.49, green: 0.94, blue: 0.94, alpha: 1)),
            Color(cgColor: CGColor(red: 0.16, green: 0.81, blue: 0.86, alpha: 1)),
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
      }
    }
  }
}

struct ExampleAppIconView_Previews: PreviewProvider {
  static var previews: some View {
    IconPreviews(
      icon: ExampleAppIconView(),
      configs: .iOS
    )
  }
}
