import SwiftUI
import AVFoundation

/// Notification sound picker view for selecting reminder sounds
struct NotificationSoundPickerView: View {
    @Binding var selectedSound: String
    @Environment(\.dismiss) private var dismiss
    
    private let sounds = NotificationSoundConfig.SoundOption.allCases
    
    var body: some View {
        List {
            ForEach(sounds) { sound in
                HStack {
                    Image(systemName: sound.previewIcon)
                        .frame(width: 30)
                        .foregroundColor(.secondary)
                    
                    Text(sound.name)
                    
                    Spacer()
                    
                    if selectedSound == sound.fileName {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                    
                    Button(action: {
                        AudioPreviewService.shared.playPreview(fileName: sound.fileName)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(sound.fileName.isEmpty)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        selectedSound = sound.fileName
                    }
                    dismiss()
                }
            }
        }
        .navigationTitle("Notification Sound")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationSoundPickerView(selectedSound: .constant("triTone.caf"))
    }
}