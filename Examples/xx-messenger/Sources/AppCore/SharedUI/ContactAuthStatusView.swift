import SwiftUI
import XXModels

public struct ContactAuthStatusView: View {
  public init(_ authStatus: Contact.AuthStatus) {
    self.authStatus = authStatus
  }

  public var authStatus: Contact.AuthStatus

  public var body: some View {
    switch authStatus {
    case .stranger:
      HStack {
        Text("Stranger")
        Spacer()
        Image(systemName: "person.fill.questionmark")
      }

    case .requesting:
      HStack {
        Text("Sending auth request")
        Spacer()
        ProgressView()
      }

    case .requested:
      HStack {
        Text("Request sent")
        Spacer()
        Image(systemName: "paperplane")
      }

    case .requestFailed:
      HStack {
        Text("Sending request failed")
        Spacer()
        Image(systemName: "xmark.diamond.fill")
          .foregroundColor(.red)
      }

    case .verificationInProgress:
      HStack {
        Text("Verification is progress")
        Spacer()
        ProgressView()
      }

    case .verified:
      HStack {
        Text("Verified")
        Spacer()
        Image(systemName: "person.fill.checkmark")
      }

    case .verificationFailed:
      HStack {
        Text("Verification failed")
        Spacer()
        Image(systemName: "xmark.diamond.fill")
          .foregroundColor(.red)
      }

    case .confirming:
      HStack {
        Text("Confirming auth request")
        Spacer()
        ProgressView()
      }

    case .confirmationFailed:
      HStack {
        Text("Confirmation failed")
        Spacer()
        Image(systemName: "xmark.diamond.fill")
          .foregroundColor(.red)
      }

    case .friend:
      HStack {
        Text("Friend")
        Spacer()
        Image(systemName: "person.fill.checkmark")
      }

    case .hidden:
      HStack {
        Text("Hidden")
        Spacer()
        Image(systemName: "eye.slash")
      }
    }
  }
}
