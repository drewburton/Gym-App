import Foundation
import UIKit

class TimerService {
    static let shared = TimerService()
    
    private var timer: Timer?
    private var endTime: Date?
    private var timeRemaining: Int = 0
    
    var onTick: ((Int) -> Void)?
    var onFinish: (() -> Void)?
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appBecameActive() {
        if let endTime = endTime {
            let remaining = Int(endTime.timeIntervalSinceNow)
            if remaining > 0 {
                timeRemaining = remaining
                onTick?(timeRemaining)
            } else {
                stop()
                onFinish?()
            }
        }
    }
    
    func start(duration: Int) {
        stop()
        timeRemaining = duration
        endTime = Date().addingTimeInterval(Double(duration))
        onTick?(timeRemaining)
        
        NotificationService.shared.scheduleRestTimerNotification(seconds: duration)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining = Int(self.endTime?.timeIntervalSinceNow ?? 0)
            self.onTick?(self.timeRemaining)
            
            if self.timeRemaining <= 0 {
                self.stop()
                self.onFinish?()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        endTime = nil
        NotificationService.shared.cancelRestTimerNotification()
    }
    
    func addTime(_ seconds: Int) {
        if let currentEndTime = endTime {
            endTime = currentEndTime.addingTimeInterval(Double(seconds))
            timeRemaining = Int(endTime?.timeIntervalSinceNow ?? 0)
            onTick?(timeRemaining)
            
            // Reschedule notification
            NotificationService.shared.cancelRestTimerNotification()
            NotificationService.shared.scheduleRestTimerNotification(seconds: timeRemaining)
        }
    }
    
    func getTimeRemaining() -> Int {
        if let endTime = endTime {
            return max(0, Int(endTime.timeIntervalSinceNow))
        }
        return 0
    }
    
    func isRunning() -> Bool {
        return endTime != nil && Int(endTime?.timeIntervalSinceNow ?? 0) > 0
    }
}
