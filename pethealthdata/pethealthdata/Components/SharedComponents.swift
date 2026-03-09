import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isDisabled ? Color.appPrimary.opacity(0.5) : Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.clear)
                .foregroundColor(isDisabled ? Color.appPrimary.opacity(0.5) : Color.appPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isDisabled ? Color.appPrimary.opacity(0.5) : Color.appPrimary, lineWidth: 1.5)
                )
        }
        .disabled(isDisabled)
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(Color.appCardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 17))
            .padding(16)
            .background(Color(hex: "F3F4F6"))
            .cornerRadius(10)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.appTextSecondary.opacity(0.5))
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                PrimaryButton(title: buttonTitle, action: buttonAction)
                    .padding(.horizontal, 48)
                    .padding(.top, 8)
            }
        }
        .padding()
    }
}

struct PetAvatarView: View {
    let pet: Pet
    var size: CGFloat = 80
    
    var body: some View {
        Group {
            if let photoData = pet.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: pet.speciesIcon)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .background(Color.speciesColor(pet.species))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.speciesColor(pet.species), lineWidth: 2)
        )
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = .appPrimary
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appTextPrimary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}
