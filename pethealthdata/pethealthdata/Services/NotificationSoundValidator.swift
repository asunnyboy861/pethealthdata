import Foundation
import AVFoundation
import UserNotifications
import AudioToolbox

/// Notification Sound Validator Service
/// 
/// Validates sound file existence, provides preview playback using iOS system sounds,
/// and offers fallback solutions.
@MainActor
final class NotificationSoundValidator: NSObject {
    static let shared = NotificationSoundValidator()
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackCompletion: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Validate if sound is valid
    /// - Parameter fileName: Sound file name
    /// - Returns: true if sound is valid
    func validateSoundFile(fileName: String) -> Bool {
        guard !fileName.isEmpty else { return true }
        return NotificationSoundConfig.isValidSound(fileName)
    }
    
    /// Play preview sound using system sound
    /// - Parameters:
    ///   - fileName: Sound file name
    ///   - completion: Completion handler when playback finishes
    func playPreview(fileName: String, completion: (() -> Void)? = nil) {
        guard !fileName.isEmpty else {
            print("⚠️ Cannot play silent sound")
            completion?()
            return
        }
        
        let soundOption = NotificationSoundConfig.soundOption(for: fileName)
        
        guard let systemSoundID = soundOption.systemSoundID else {
            print("⚠️ No system sound ID for: \(fileName)")
            completion?()
            return
        }
        
        playbackCompletion = completion
        
        AudioServicesPlaySystemSoundWithCompletion(systemSoundID) { [weak self] in
            Task { @MainActor in
                self?.playbackCompletion?()
                self?.playbackCompletion = nil
            }
        }
        
        print("✅ Playing system sound: \(soundOption.name) (ID: \(systemSoundID))")
    }
    
    /// Stop preview playback
    func stopPreview() {
        playbackCompletion = nil
    }
    
    /// Get notification sound for UNNotificationContent
    /// - Parameter fileName: User-selected sound file name
    /// - Returns: UNNotificationSound object
    func notificationSound(for fileName: String) -> UNNotificationSound {
        guard !fileName.isEmpty, fileName != "silent" else {
            return .default
        }
        
        let soundOption = NotificationSoundConfig.soundOption(for: fileName)
        
        if soundOption.fileName == "default" {
            return .default
        }
        
        if let systemSoundID = soundOption.systemSoundID {
            let soundName = UNNotificationSoundName(rawValue: soundOption.fileName)
            return UNNotificationSound(named: soundName)
        }
        
        return .default
    }
}
