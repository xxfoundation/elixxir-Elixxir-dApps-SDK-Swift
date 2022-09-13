// MIT License
//
// Copyright (c) 2022 Dariusz Rybicki Darrarski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Source: https://github.com/darrarski/swiftui-tabs-view/blob/be6865324ed9651c22df36540f932c10ab9c7c34/Sources/SwiftUITabsView/ToolbarViewModifier.swift

import SwiftUI

/// Describes position of the toolbar.
public enum ToolbarPosition: Equatable {
  /// Bar positioned above the content.
  case top

  /// Tabs bar positioned below the content.
  case bottom

  var verticalEdge: VerticalEdge {
    switch self {
    case .top: return .top
    case .bottom: return .bottom
    }
  }

  var frameAlignment: Alignment {
    switch self {
    case .top: return .top
    case .bottom: return .bottom
    }
  }
}

struct ToolbarPositionKey: EnvironmentKey {
  static var defaultValue: ToolbarPosition = .bottom
}

extension EnvironmentValues {
  var toolbarPosition: ToolbarPosition {
    get { self[ToolbarPositionKey.self] }
    set { self[ToolbarPositionKey.self] = newValue }
  }
}

extension View {
  public func toolbar<Bar: View>(
    position: ToolbarPosition = .bottom,
    ignoresKeyboard: Bool = true,
    frameChangeAnimation: Animation? = .default,
    @ViewBuilder bar: @escaping () -> Bar
  ) -> some View {
    modifier(ToolbarViewModifier(
      ignoresKeyboard: ignoresKeyboard,
      frameChangeAnimation: frameChangeAnimation,
      bar: bar
    ))
    .environment(\.toolbarPosition, position)
  }
}

struct ToolbarViewModifier<Bar: View>: ViewModifier {
  init(
    ignoresKeyboard: Bool = true,
    frameChangeAnimation: Animation? = .default,
    @ViewBuilder bar: @escaping () -> Bar
  ) {
    self.ignoresKeyboard = ignoresKeyboard
    self.frameChangeAnimation = frameChangeAnimation
    self.bar = bar
  }

  var ignoresKeyboard: Bool
  var frameChangeAnimation: Animation?
  var bar: () -> Bar

  @Environment(\.toolbarPosition) var position
  @State var contentFrame: CGRect?
  @State var toolbarFrame: CGRect?
  @State var toolbarSafeAreaInset: CGSize = .zero

  var keyboardSafeAreaEdges: Edge.Set {
    guard ignoresKeyboard else { return [] }
    switch position {
    case .top: return .top
    case .bottom: return .bottom
    }
  }

  func body(content: Content) -> some View {
    ZStack {
      content
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbarSafeAreaInset()
        .geometryReader(
          geometry: { $0.frame(in: .global) },
          onChange: { frame in
            withAnimation(contentFrame == nil ? .none : frameChangeAnimation) {
              contentFrame = frame
              toolbarSafeAreaInset = makeToolbarSafeAreaInset()
            }
          }
        )

      bar()
        .geometryReader(
          geometry: { $0.frame(in: .global) },
          onChange: { frame in
            withAnimation(toolbarFrame == nil ? .none : frameChangeAnimation) {
              toolbarFrame = frame
              toolbarSafeAreaInset = makeToolbarSafeAreaInset()
            }
          }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position.frameAlignment)
        .ignoresSafeArea(.keyboard, edges: keyboardSafeAreaEdges)
    }
    .environment(\.toolbarSafeAreaInset, toolbarSafeAreaInset)
  }

  func makeToolbarSafeAreaInset() -> CGSize {
    guard let contentFrame = contentFrame,
          let toolbarFrame = toolbarFrame
    else { return .zero }

    var size = contentFrame.intersection(toolbarFrame).size
    size.width = max(0, size.width)
    size.height = max(0, size.height)

    return size
  }
}

struct ToolbarSafeAreaInsetKey: EnvironmentKey {
  static var defaultValue: CGSize = .zero
}

extension EnvironmentValues {
  var toolbarSafeAreaInset: CGSize {
    get { self[ToolbarSafeAreaInsetKey.self] }
    set { self[ToolbarSafeAreaInsetKey.self] = newValue }
  }
}

struct ToolbarSafeAreaInsetViewModifier: ViewModifier {
  @Environment(\.toolbarPosition) var position
  @Environment(\.toolbarSafeAreaInset) var toolbarSafeAreaInset

  func body(content: Content) -> some View {
    content
      .safeAreaInset(edge: position.verticalEdge) {
        Color.clear.frame(
          width: toolbarSafeAreaInset.width,
          height: toolbarSafeAreaInset.height
        )
      }
  }
}

extension View {
  /// Add safe area inset for toolbar.
  ///
  /// Use this modifier if your content is embedded in `NavigationView`.
  /// Apply it on the content inside the `NavigationView`.
  ///
  /// - Returns: View with additional safe area insets matching the toolbar.
  public func toolbarSafeAreaInset() -> some View {
    modifier(ToolbarSafeAreaInsetViewModifier())
  }
}

#if DEBUG
struct ToolbarViewModifier_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        ForEach(1..<21) { row in
          VStack(alignment: .leading, spacing: 0) {
            Text("Row #\(row)")
            TextField("Text", text: .constant(""))
          }
          .padding()
          .background(Color.accentColor.opacity(row % 2 == 0 ? 0.1 : 0.15))
        }
      }
    }
    .toolbar(ignoresKeyboard: true) {
      Text("Bottom Bar")
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
#if os(macOS)
    .frame(width: 640, height: 480)
#endif
  }
}
#endif
