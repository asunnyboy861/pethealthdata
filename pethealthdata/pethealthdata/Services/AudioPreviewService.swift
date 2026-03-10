import Foundation
import AVFoundation

/// Audio preview service for notification sounds
final class AudioPreviewService {
    static let shared = AudioPreviewService()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    /// Play a preview sound
    /// - Parameter fileName: The sound file name (e.g., "triTone.caf")
    func playPreview(fileName: String) {
        guard !fileName.isEmpty else {
            // Silent - do nothing
            return
        }
        
        let soundName = String(fileName.dropLast(4)) // Remove .caf extension
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "caf") else {
            print("Sound file not found: \(fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    /// Stop playing preview
    func stopPreview() {
        audioPlayer?.stop()
    }
}