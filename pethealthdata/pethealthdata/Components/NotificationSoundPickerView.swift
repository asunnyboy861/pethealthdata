import SwiftUI
import AVFoundation

/// Notification sound picker view for selecting reminder sounds
/// Enhanced with better visual feedback and preview functionality
struct NotificationSoundPickerView: View {
    @Binding var selectedSound: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var playingSound: String?
    @State private var showingPermissionAlert = false
    
    private let sounds = NotificationSoundConfig.SoundOption.allCases
    private let soundValidator = NotificationSoundValidator.shared
    
    var body: some View {
        List {
            silentOptionRow
            
            Divider()
            
            ForEach(sounds.filter { !$0.fileName.isEmpty }) { sound in
                soundRow(for: sound)
            }
        }
        .navigationTitle("Notification Sound")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var silentOptionRow: some View {
        Button(action: {
            selectSound("")
        }) {
            HStack(spacing: 12) {
                Image(systemName: "speaker.slash.fill")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.appTextSecondary)
                    .background(
                        Circle()
                            .fill(Color.appBackground)
                            .frame(width: 40, height: 40)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Silent")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appTextPrimary)
                    Text("No sound for notifications")
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                selectionIndicator(isSelected: selectedSound.isEmpty || selectedSound == "silent")
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private func soundRow(for sound: NotificationSoundConfig.SoundOption) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                selectSound(sound.fileName)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: sound.previewIcon)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.appPrimary)
                        .background(
                            Circle()
                                .fill(Color.appPrimary.opacity(0.1))
                                .frame(width: 40, height: 40)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sound.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appTextPrimary)
                        Text(sound.description)
                            .font(.system(size: 13))
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    Spacer()
                    
                    selectionIndicator(isSelected: selectedSound == sound.fileName)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                playPreview(for: sound)
            }) {
                Image(systemName: isPlaying(sound.fileName) ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.appPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.appPrimary.opacity(isPlaying(sound.fileName) ? 0.2 : 0.1))
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    private func selectionIndicator(isSelected: Bool) -> some View {
        Group {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.appPrimary)
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 22))
                    .foregroundColor(.appBorder)
            }
        }
    }
    
    private func isPlaying(_ fileName: String) -> Bool {
        playingSound == fileName
    }
    
    private func selectSound(_ fileName: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedSound = fileName
        }
    }
    
    private func playPreview(for sound: NotificationSoundConfig.SoundOption) {
        if let currentPlaying = playingSound, currentPlaying != sound.fileName {
            soundValidator.stopPreview()
        }
        
        if isPlaying(sound.fileName) {
            soundValidator.stopPreview()
            playingSound = nil
        } else {
            playingSound = sound.fileName
            soundValidator.playPreview(fileName: sound.fileName) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        playingSound = nil
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSoundPickerView(selectedSound: .constant("triTone.caf"))
    }
}
