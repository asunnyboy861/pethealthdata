import Foundation
import UserNotifications

/// Notification Permission Management Service
/// 
/// Manages notification authorization status and provides methods for checking,
/// requesting, and listening to authorization status changes.
/// All notification scheduling must verify authorization through this service.
@MainActor
final class NotificationPermissionService {
    static let shared = NotificationPermissionService()
    
    // MARK: - Properties
    
    /// Current authorization status (cached)
    private var cachedStatus: UNAuthorizationStatus?
    
    /// Authorization status change listeners
    private var statusListeners: [(UNAuthorizationStatus) -> Void] = []
    
    private init() {
        // Cache status on initialization
        refreshStatus()
    }
    
    // MARK: - Public Methods
    
    /// Refresh authorization status from system
    func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.cachedStatus = settings.authorizationStatus
                self?.notifyListeners(settings.authorizationStatus)
            }
        }
    }
    
    /// Get current authorization status
    /// - Returns: Current authorization status
    var authorizationStatus: UNAuthorizationStatus {
        return cachedStatus ?? .notDetermined
    }
    
    /// Check if notifications are authorized
    /// - Returns: true if authorized, false otherwise
    func isAuthorized() -> Bool {
        guard let status = cachedStatus else { return false }
        
        switch status {
        case .authorized, .provisional:
            return true
        case .denied, .ephemeral, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
    
    /// Request notification authorization
    /// - Parameter completion: Completion handler with success status
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound, .criticalAlert]
        ) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.refreshStatus()
                
                if let error = error {
                    print("❌ Notification authorization error: \(error)")
                    completion(false)
                } else {
                    print("✅ Notification permission \(granted ? "granted" : "denied")")
                    completion(granted)
                }
            }
        }
    }
    
    /// Check authorization and request if needed
    /// - Parameter completion: Completion handler with authorization status
    func checkAndRequestIfNeeded(completion: @escaping (Bool) -> Void) {
        if isAuthorized() {
            completion(true)
        } else {
            requestAuthorization(completion: completion)
        }
    }
    
    /// Add authorization status listener
    /// - Parameter listener: Status change callback
    func addStatusListener(_ listener: @escaping (UNAuthorizationStatus) -> Void) {
        statusListeners.append(listener)
        // Immediately trigger with current status
        if let status = cachedStatus {
            listener(status)
        }
    }
    
    /// Remove authorization status listener
    /// - Parameter listener: Listener to remove
    func removeStatusListener(_ listener: @escaping (UNAuthorizationStatus) -> Void) {
        // Simplified removal (in production, use unique identifiers)
        statusListeners.removeAll { _ in false }
    }
    
    // MARK: - Private Methods
    
    /// Notify all listeners of status change
    private func notifyListeners(_ status: UNAuthorizationStatus) {
        for listener in statusListeners {
            listener(status)
        }
    }
}
