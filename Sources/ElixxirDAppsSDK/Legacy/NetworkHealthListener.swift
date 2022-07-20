//import Bindings
//
//public struct NetworkHealthListener {
//  public var listen: (@escaping (Bool) -> Void) -> Cancellable
//
//  public func callAsFunction(callback: @escaping (Bool) -> Void) -> Cancellable {
//    listen(callback)
//  }
//}
//
//extension NetworkHealthListener {
//  public static func live(bindingsClient: BindingsCmix) -> NetworkHealthListener {
//    NetworkHealthListener { callback in
//      let listener = Listener(onCallback: callback)
//      let id = bindingsClient.registerNetworkHealthCB(listener)
//      return Cancellable {
//        bindingsClient.unregisterNetworkHealthCB(id)
//      }
//    }
//  }
//}
//
//private final class Listener: NSObject, BindingsNetworkHealthCallbackProtocol {
//  init(onCallback: @escaping (Bool) -> Void) {
//    self.onCallback = onCallback
//    super.init()
//  }
//
//  let onCallback: (Bool) -> Void
//
//  func callback(_ p0: Bool) {
//    onCallback(p0)
//  }
//}
//
//#if DEBUG
//extension NetworkHealthListener {
//  public static let failing = NetworkHealthListener { _ in
//    fatalError("Not implemented")
//  }
//}
//#endif
