import Foundation
import WatchConnectivity

class WatchConnectivityService: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityService()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionStoreComponents(for session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
    
    // MARK: - Data Sync Methods
    
    func sendActiveWorkoutState(_ state: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(state, replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        } else {
            do {
                try WCSession.default.updateApplicationContext(state)
            } catch {
                print("Error updating application context: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle incoming messages from Watch
        NotificationCenter.default.post(name: Notification.Name("ReceivedWatchMessage"), object: nil, userInfo: message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Handle background context updates
        NotificationCenter.default.post(name: Notification.Name("ReceivedWatchContext"), object: nil, userInfo: applicationContext)
    }
}
