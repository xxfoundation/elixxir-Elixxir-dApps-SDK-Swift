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
// Source: https://github.com/darrarski/swiftui-tabs-view/blob/be6865324ed9651c22df36540f932c10ab9c7c34/Sources/SwiftUITabsView/GeometryReaderViewModifier.swift

import SwiftUI

extension View {
  func geometryReader<Geometry: Codable>(
    geometry: @escaping (GeometryProxy) -> Geometry,
    onChange: @escaping (Geometry) -> Void
  ) -> some View {
    modifier(GeometryReaderViewModifier(
      geometry: geometry,
      onChange: onChange
    ))
  }
}

struct GeometryReaderViewModifier<Geometry: Codable>: ViewModifier {
  var geometry: (GeometryProxy) -> Geometry
  var onChange: (Geometry) -> Void

  func body(content: Content) -> some View {
    content
      .background {
        GeometryReader { geometryProxy in
          Color.clear
            .preference(key: GeometryPreferenceKey.self, value: {
              let geometry = self.geometry(geometryProxy)
              let data = try? JSONEncoder().encode(geometry)
              return data
            }())
            .onPreferenceChange(GeometryPreferenceKey.self) { data in
              if let data = data,
                 let geomerty = try? JSONDecoder().decode(Geometry.self, from: data)
              {
                onChange(geomerty)
              }
            }
        }
      }
  }
}

struct GeometryPreferenceKey: PreferenceKey {
  static var defaultValue: Data? = nil

  static func reduce(value: inout Data?, nextValue: () -> Data?) {
    value = nextValue()
  }
}

#if DEBUG
struct GeometryReaderModifier_Previews: PreviewProvider {
  struct Preview: View {
    @State var size: CGSize = .zero

    var body: some View {
      VStack {
        Text("Hello, World!")
          .font(.largeTitle)
          .background(Color.accentColor.opacity(0.15))
          .geometryReader(
            geometry: \.size,
            onChange: { size = $0 }
          )

        Text("\(Int(size.width.rounded())) x \(Int(size.height.rounded()))")
          .font(.caption)
          .frame(width: size.width, height: size.height)
          .background(Color.accentColor.opacity(0.15))
      }
    }
  }

  static var previews: some View {
    Preview()
#if os(macOS)
      .frame(width: 640, height: 480)
#endif
  }
}
#endif
