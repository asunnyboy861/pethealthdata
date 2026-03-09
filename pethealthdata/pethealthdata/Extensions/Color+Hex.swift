import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let appPrimary = Color(hex: "0A84FF")
    static let appSecondary = Color(hex: "FF6B6B")
    static let appAccent = Color(hex: "FFD93D")
    static let appBackground = Color(hex: "F8F9FA")
    static let appCardBackground = Color(hex: "FFFFFF")
    static let appTextPrimary = Color(hex: "1A1A1A")
    static let appTextSecondary = Color(hex: "6B7280")
    static let appSuccess = Color(hex: "34C759")
    static let appWarning = Color(hex: "FF9500")
    static let appError = Color(hex: "FF3B30")
    
    static let dogColor = Color(hex: "0A84FF")
    static let catColor = Color(hex: "FF6B9D")
    static let birdColor = Color(hex: "34C759")
    static let otherPetColor = Color(hex: "FFA726")
    
    static func speciesColor(_ species: String) -> Color {
        switch species.lowercased() {
        case "dog": return .dogColor
        case "cat": return .catColor
        case "bird": return .birdColor
        default: return .otherPetColor
        }
    }
}
