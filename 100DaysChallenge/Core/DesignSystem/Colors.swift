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
    static let accentCoralRed    = Color(hex: "#F56B6B")
    static let accentSunsetOrange = Color(hex: "#FB9A45")
    static let accentFreshGreen = Color(hex: "#6BCF94")
    static let accentOceanTeal = Color(hex: "#4ECDC4")
    static let accentSkyBlue = Color(hex: "#5C9FFF")
    static let accentRoyalPurple = Color(hex: "#9B6BFF")
    static let accentMagenta = Color(hex: "#EE7FB3")
    static let accentSoftLavender = Color(hex: "#C7B7FF")
    static let accentDarkBrown = Color(hex: "#76574A")
    static let accentDeepNavy = Color(hex: "#24304D")
    
    // MARK: - Onboarding Colors
    static let onboardingBlue = Color(hex: "#5C9FFF")
    static let onboardingMagenta = Color(hex: "#EE7FB3")
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
    static let textError = Color.accentCoralRed
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
    
    static let gradientTipsCard = LinearGradient(
        colors: [Color(hex: "#FEF9F5"), Color(hex: "#FDF7F2")],
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

// MARK: - Color Preview Data Structures
struct ColorPreviewItem: Identifiable {
    let name: String
    let color: Color
    
    var id: String { name }
}

struct GradientPreviewItem: Identifiable {
    let name: String
    let gradient: LinearGradient
    
    var id: String { name }
}

// MARK: - Shareable Color Constants for Preview
enum ColorPreviewData {
    // Accent Colors - automatically derived from ChallengeAccentColor.all
    static var accentColors: [ColorPreviewItem] {
        ChallengeAccentColor.all.map {
            ColorPreviewItem(name: $0.name, color: $0.color)
        }
    }
    
    // Onboarding Colors - automatically references Color extension properties
    static var onboardingColors: [ColorPreviewItem] {
        [
            ColorPreviewItem(name: "Sky Blue", color: .onboardingBlue),
            ColorPreviewItem(name: "Magenta", color: .onboardingMagenta),
            ColorPreviewItem(name: "Fresh Green", color: .onboardingGreen)
        ]
    }
    
    // Gray Scale - automatically references Color extension properties
    static var grayScaleColors: [ColorPreviewItem] {
        [
            ColorPreviewItem(name: "Gray 50", color: .gray50),
            ColorPreviewItem(name: "Gray 100", color: .gray100),
            ColorPreviewItem(name: "Gray 200", color: .gray200),
            ColorPreviewItem(name: "Gray 400", color: .gray400),
            ColorPreviewItem(name: "Gray 500", color: .gray500),
            ColorPreviewItem(name: "Gray 600", color: .gray600),
            ColorPreviewItem(name: "Gray 700", color: .gray700),
            ColorPreviewItem(name: "Gray 900", color: .gray900)
        ]
    }
    
    // Semantic Colors - automatically references Color extension properties
    static var semanticColors: [ColorPreviewItem] {
        [
            ColorPreviewItem(name: "Background", color: .background),
            ColorPreviewItem(name: "Text Primary", color: .textPrimary),
            ColorPreviewItem(name: "Text Secondary", color: .textSecondary),
            ColorPreviewItem(name: "Text Tertiary", color: .textTertiary),
            ColorPreviewItem(name: "Text Error", color: .textError),
            ColorPreviewItem(name: "Border", color: .border),
            ColorPreviewItem(name: "Input Background", color: .inputBackground)
        ]
    }
    
    // Tab Bar Colors - automatically references Color extension properties
    static var tabBarColors: [ColorPreviewItem] {
        [
            ColorPreviewItem(name: "Active", color: .tabBarActive),
            ColorPreviewItem(name: "Inactive", color: .tabBarInactive)
        ]
    }
    
    // Gradients - automatically references Color extension properties
    static var gradients: [GradientPreviewItem] {
        [
            GradientPreviewItem(name: "Orange Pink", gradient: Color.gradientOrangePink),
            GradientPreviewItem(name: "Splash", gradient: Color.gradientSplash)
        ]
    }
}

// MARK: - Challenge Accent Color Options
struct ChallengeAccentColor {
    let name: String
    let color: Color
    
    static let all: [ChallengeAccentColor] = [
        ChallengeAccentColor(name: "Coral Red", color: .accentCoralRed),
        ChallengeAccentColor(name: "Sunset Orange", color: .accentSunsetOrange),
        ChallengeAccentColor(name: "Fresh Green", color: .accentFreshGreen),
        ChallengeAccentColor(name: "Ocean Teal", color: .accentOceanTeal),
        ChallengeAccentColor(name: "Sky Blue", color: .accentSkyBlue),
        ChallengeAccentColor(name: "Soft Lavender", color: .accentSoftLavender),
        ChallengeAccentColor(name: "Royal Purple", color: .accentRoyalPurple),
        ChallengeAccentColor(name: "Magenta", color: .accentMagenta),
        ChallengeAccentColor(name: "Dark Brown", color: .accentDarkBrown),
        ChallengeAccentColor(name: "Deep Navy", color: .accentDeepNavy)
    ]
}

// MARK: - Color Preview
struct ColorPreviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Accent Colors
                ColorSection(
                    title: "Accent Colors",
                    items: ColorPreviewData.accentColors
                )
                
                // Onboarding Colors
                ColorSection(
                    title: "Onboarding Colors",
                    items: ColorPreviewData.onboardingColors
                )
                
                // Gray Scale
                ColorSection(
                    title: "Gray Scale",
                    items: ColorPreviewData.grayScaleColors
                )
                
                // Semantic Colors
                ColorSection(
                    title: "Semantic Colors",
                    items: ColorPreviewData.semanticColors
                )
                
                // Tab Bar Colors
                ColorSection(
                    title: "Tab Bar Colors",
                    items: ColorPreviewData.tabBarColors
                )
                
                // Gradients
                GradientSection(
                    title: "Gradients",
                    items: ColorPreviewData.gradients
                )
            }
            .padding(.vertical, Spacing.xl)
        }
        .background(Color.background)
    }
}

struct ColorSection: View {
    let title: String
    let items: [ColorPreviewItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(.heading2)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.md) {
                ForEach(items) { item in
                    ColorSwatch(name: item.name, color: item.color)
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
    }
}

struct GradientSection: View {
    let title: String
    let items: [GradientPreviewItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(.heading2)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: Spacing.md) {
                ForEach(items) { item in
                    GradientSwatch(name: item.name, gradient: item.gradient)
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(color)
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(Color.border, lineWidth: 1)
                )
            
            Text(name)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

struct GradientSwatch: View {
    let name: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(name)
                .font(.body)
                .foregroundColor(.textPrimary)
            
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(gradient)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(Color.border, lineWidth: 1)
                )
        }
    }
}

#Preview {
    ColorPreviewView()
}
