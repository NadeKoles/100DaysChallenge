//
//  Colors.swift
//  100DaysChallenge
//
//  Design tokens extracted from Figma export
//

import SwiftUI

extension Color {
    // MARK: - Accent Colors (Challenge-specific)
    // Warm, visually distinct palette for challenge selection
    static let accentCoralRed = Color(hex: "#FF6B6B")
    static let accentSunsetOrange = Color(hex: "#FF9D5C")
    static let accentSunnyYellow = Color(hex: "#FFD23F")
    static let accentFreshGreen = Color(hex: "#6BCF94")
    static let accentOceanTeal = Color(hex: "#4ECDC4")
    static let accentSkyBlue = Color(hex: "#5C9FFF")
    static let accentRoyalPurple = Color(hex: "#9B6BFF")
    static let accentMagenta = Color(hex: "#FF6BB5")
    static let accentWarmBrown = Color(hex: "#C17E5D")
    static let accentGold = Color(hex: "#E6A23C")
    
    // MARK: - Onboarding Colors
    static let onboardingBlue = Color(hex: "#5C9FFF")
    static let onboardingRed = Color(hex: "#FF6B6B")
    static let onboardingGreen = Color(hex: "#6BCF94")
    
    // MARK: - Gray Scale
    static let gray50 = Color(hex: "#F9FAFB")
    static let gray100 = Color(hex: "#F3F4F6")
    static let gray200 = Color(hex: "#E5E7EB")
    static let gray400 = Color(hex: "#9CA3AF")
    static let gray500 = Color(hex: "#6B7280")
    static let gray600 = Color(hex: "#4B5563")
    static let gray700 = Color(hex: "#374151")
    static let gray900 = Color(hex: "#111827")
    
    // MARK: - Semantic Colors
    static let background = Color.white
    static let textPrimary = Color.gray900
    static let textSecondary = Color.gray600
    static let textTertiary = Color.gray500
    static let border = Color.gray200
    static let inputBackground = Color.gray50
    
    // MARK: - Tab Bar
    static let tabBarActive = accentCoralRed
    static let tabBarInactive = Color.gray400
    
    // MARK: - Gradients
    static let gradientOrangePink = LinearGradient(
        colors: [Color(hex: "#FF9D5C"), Color(hex: "#FF6BB5")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let gradientOrangePinkStart = Color(hex: "#FF9D5C")
    static let gradientOrangePinkEnd = Color(hex: "#FF6BB5")
    
    static let gradientSplash = LinearGradient(
        colors: [Color.white, Color(hex: "#FFF7ED")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Challenge Accent Color Options
struct ChallengeAccentColor {
    let name: String
    let color: Color
    
    static let all: [ChallengeAccentColor] = [
        ChallengeAccentColor(name: "Coral Red", color: .accentCoralRed),
        ChallengeAccentColor(name: "Sunset Orange", color: .accentSunsetOrange),
        ChallengeAccentColor(name: "Sunny Yellow", color: .accentSunnyYellow),
        ChallengeAccentColor(name: "Fresh Green", color: .accentFreshGreen),
        ChallengeAccentColor(name: "Ocean Teal", color: .accentOceanTeal),
        ChallengeAccentColor(name: "Sky Blue", color: .accentSkyBlue),
        ChallengeAccentColor(name: "Royal Purple", color: .accentRoyalPurple),
        ChallengeAccentColor(name: "Magenta", color: .accentMagenta),
        ChallengeAccentColor(name: "Warm Brown", color: .accentWarmBrown),
        ChallengeAccentColor(name: "Gold", color: .accentGold)
    ]
}

