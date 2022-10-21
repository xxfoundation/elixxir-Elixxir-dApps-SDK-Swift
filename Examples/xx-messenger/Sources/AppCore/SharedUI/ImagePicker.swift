import UIKit
import SwiftUI

public struct ImagePicker: UIViewControllerRepresentable {
  public init(onImport: @escaping (UIImage) -> Void) {
    self.onImport = onImport
  }

  var onImport: (UIImage) -> Void
  @Environment(\.presentationMode) private var presentationMode

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public func makeUIViewController(context: Context) -> UIImagePickerController {
    let controller = UIImagePickerController()
    controller.delegate = context.coordinator
    return controller
  }

  public func updateUIViewController(
    _ uiViewController: UIImagePickerController,
    context: Context
  ) {}
}

extension ImagePicker {
  public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    init(_ picker: ImagePicker) {
      self.picker = picker
      super.init()
    }

    public func imagePickerController(
      _ controller: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
      if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        DispatchQueue.main.async {
          self.picker.onImport(image)
        }
      }
      picker.presentationMode.wrappedValue.dismiss()
    }

    let picker: ImagePicker
  }
}
