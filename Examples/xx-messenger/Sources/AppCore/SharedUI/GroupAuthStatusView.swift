import SwiftUI
import XXModels

public struct GroupAuthStatusView: View {
  public init(_ authStatus: XXModels.Group.AuthStatus) {
    self.authStatus = authStatus
  }

  public var authStatus: XXModels.Group.AuthStatus

  public var body: some View {
    switch authStatus {
    case .pending:
      HStack {
        Text("Pending")
        Spacer()
        Image(systemName: "envelope.badge")
      }

    case .deleting:
      HStack {
        Text("Deleting")
        Spacer()
        ProgressView()
      }

    case .participating:
      HStack {
        Text("Participating")
        Spacer()
        Image(systemName: "checkmark")
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

#if DEBUG
struct GroupAuthStatusView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      Form {
        Section { GroupAuthStatusView(.pending) }
        Section { GroupAuthStatusView(.deleting) }
        Section { GroupAuthStatusView(.participating) }
        Section { GroupAuthStatusView(.hidden) }
      }
    }
  }
}
#endif
