import Foundation

/// Notification sound configuration for pet health reminders
enum NotificationSoundConfig {
    
    /// Sound option for user selection
    struct SoundOption: Identifiable, Hashable {
        let id: String
        let name: String
        let fileName: String
        let previewIcon: String
        
        static let allCases: [SoundOption] = [
            .init(id: "triTone", name: "Tri-Tone", fileName: "triTone.caf", previewIcon: "music.note"),
            .init(id: "bamboo", name: "Bamboo", fileName: "bamboo.caf", previewIcon: "music.note"),
            .init(id: "default", name: "Default", fileName: "default.caf", previewIcon: "bell"),
            .init(id: "note", name: "Note", fileName: "note.caf", previewIcon: "music.note"),
            .init(id: "pop", name: "Pop", fileName: "pop.caf", previewIcon: "bubble.left"),
            .init(id: "sonar", name: "Sonar", fileName: "Sonar.caf", previewIcon: "waveform"),
            .init(id: "silent", name: "Silent", fileName: "", previewIcon: "bell.slash")
        ]
        
        static let `default` = SoundOption(id: "triTone", name: "Tri-Tone", fileName: "triTone.caf", previewIcon: "music.note")
        static let medicationDefault = SoundOption(id: "bamboo", name: "Bamboo", fileName: "bamboo.caf", previewIcon: "music.note")
    }
    
    /// Get URL for a sound file
    static func soundURL(for fileName: String) -> URL? {
        guard !fileName.isEmpty else { return nil }
        let soundName = String(fileName.dropLast(4)) // Remove .caf extension
        return Bundle.main.url(forResource: soundName, withExtension: "caf")
    }
    
    /// Check if a sound file exists
    static func soundExists(fileName: String) -> Bool {
        guard !fileName.isEmpty else { return true } // Silent has no file
        return soundURL(for: fileName) != nil
    }
}