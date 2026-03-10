import Foundation
import AudioToolbox

/// Notification sound configuration for pet health reminders
/// Uses iOS system built-in sounds for better compatibility
enum NotificationSoundConfig {
    
    /// Sound option for user selection
    struct SoundOption: Identifiable, Hashable {
        let id: String
        let name: String
        let fileName: String
        let previewIcon: String
        let description: String
        let systemSoundID: UInt32?
        
        /// 经过验证的 iOS 系统声音
        /// 参考: https://github.com/TUNER88/iOSSystemSoundsLibrary
        static let allCases: [SoundOption] = [
            // 新邮件接收 (经典三音)
            .init(id: "newMail", name: "Tri-Tone", fileName: "newMail", previewIcon: "music.note", description: "Classic three-tone alert", systemSoundID: 1000),
            // 邮件发送成功
            .init(id: "mailSent", name: "Sent", fileName: "mailSent", previewIcon: "paperplane.fill", description: "Message sent sound", systemSoundID: 1001),
            // 提醒事项提醒
            .init(id: "reminder", name: "Reminder", fileName: "reminder", previewIcon: "bell.fill", description: "Reminder alert", systemSoundID: 1005),
            // 短信接收
            .init(id: "smsReceived", name: "SMS", fileName: "smsReceived", previewIcon: "message.fill", description: "SMS received", systemSoundID: 1007),
            // 日历提醒
            .init(id: "calendarAlert", name: "Calendar", fileName: "calendarAlert", previewIcon: "calendar.badge.clock", description: "Calendar alert", systemSoundID: 1008),
            // 拍照快门声
            .init(id: "photoShutter", name: "Shutter", fileName: "photoShutter", previewIcon: "camera.fill", description: "Camera shutter", systemSoundID: 1108),
            // 锁定屏幕
            .init(id: "lock", name: "Lock", fileName: "lock", previewIcon: "lock.fill", description: "Screen lock", systemSoundID: 1100),
            // 解锁屏幕
            .init(id: "unlock", name: "Unlock", fileName: "unlock", previewIcon: "lock.open.fill", description: "Screen unlock", systemSoundID: 1101),
            // 按键音
            .init(id: "keyPress", name: "Key Press", fileName: "keyPress", previewIcon: "keyboard", description: "Key press click", systemSoundID: 1103),
            // 支付成功
            .init(id: "paymentSuccess", name: "Success", fileName: "paymentSuccess", previewIcon: "checkmark.circle.fill", description: "Payment success", systemSoundID: 1407),
            // 支付失败
            .init(id: "paymentFail", name: "Fail", fileName: "paymentFail", previewIcon: "xmark.circle.fill", description: "Payment failed", systemSoundID: 1408),
            // 静音选项
            .init(id: "silent", name: "Silent", fileName: "", previewIcon: "bell.slash", description: "No sound", systemSoundID: nil)
        ]
        
        static let `default` = SoundOption(id: "newMail", name: "Tri-Tone", fileName: "newMail", previewIcon: "music.note", description: "Classic three-tone alert", systemSoundID: 1000)
        static let medicationDefault = SoundOption(id: "reminder", name: "Reminder", fileName: "reminder", previewIcon: "bell.fill", description: "Reminder alert", systemSoundID: 1005)
    }
    
    /// Get sound option by file name
    static func soundOption(for fileName: String) -> SoundOption {
        return SoundOption.allCases.first { $0.fileName == fileName } ?? .default
    }
    
    /// Check if a sound file name is valid
    static func isValidSound(_ fileName: String) -> Bool {
        return SoundOption.allCases.contains { $0.fileName == fileName }
    }
}
