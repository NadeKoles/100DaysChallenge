//
//  PrimaryButton.swift
//  100DaysChallenge
//
//  Reusable primary button component for all primary action buttons
//

import SwiftUI

struct PrimaryButton: View {
    enum Style {
        case filled
        case outlined
        case solid(Color)
        case secondary
    }
    
    private enum Metrics {
        static let height: CGFloat = 56
        static let horizontalPadding: CGFloat = Spacing.xl
        static let iconTextSpacing: CGFloat = Spacing.sm
        static let iconSize: CGFloat = 25
        static let systemIconSize: CGFloat = 18
    }
    
    // Animation parameters - single source of truth for press interaction
    private enum PressAnimation {
        static let pressedScale: CGFloat = 0.97
        static let pressedYTranslation: CGFloat = 0.8
        static let pressedShadowRadius: CGFloat = 4.0
        static let pressedShadowY: CGFloat = 2.0
        static let animation: SwiftUI.Animation = .spring(response: 0.22, dampingFraction: 0.78)
    }
    
    let title: String
    let action: () -> Void
    let icon: Image?
    let iconSystemNameLeft: String?
    let iconSystemNameRight: String?
    let style: Style
    let isEnabled: Bool
    let isLoading: Bool
    
    init(
        title: String,
        action: @escaping () -> Void,
        icon: Image? = nil,
        iconSystemNameLeft: String? = nil,
        iconSystemNameRight: String? = nil,
        style: Style = .filled,
        isEnabled: Bool = true,
        isLoading: Bool = false
    ) {
        self.title = title
        self.action = action
        self.icon = icon
        self.iconSystemNameLeft = iconSystemNameLeft
        self.iconSystemNameRight = iconSystemNameRight
        self.style = style
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }
    
    // Disabled accent look (0.72 opacity on white) as solid color; overlay = 1 - this.
    private enum DisabledAppearance {
        static let accentVisibility: Double = 0.72
        static let overlayOpacity: Double = 1 - accentVisibility
    }

    private var isInactive: Bool { !isEnabled || isLoading }

    private var textColor: Color {
        switch style {
        case .filled, .solid:
            return .white
        case .outlined:
            return .textPrimary
        case .secondary:
            return .textSecondary
        }
    }

    private var buttonOpacity: Double {
        switch style {
        case .filled, .solid:
            return 1 // Opaque; disabled look handled via background
        case .outlined, .secondary:
            return isInactive ? DisabledAppearance.accentVisibility : 1
        }
    }
    
    private var shouldHaveShadow: Bool {
        switch style {
        case .filled, .solid:
            return true
        case .outlined, .secondary:
            return false
        }
    }
    
    private var shadowConfig: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        return (color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var hasLeftIcon: Bool {
        icon != nil || iconSystemNameLeft != nil
    }
    
    private var hasRightIcon: Bool {
        iconSystemNameRight != nil
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.iconTextSpacing) {
                if !hasLeftIcon && !hasRightIcon {
                    // Center text when no icons
                    Spacer()
                }
                
                leftIcon
                Text(title)
                    .font(.label)
                    .foregroundColor(textColor)
                
                if hasRightIcon {
                    rightIcon
                } else if !hasLeftIcon && !hasRightIcon {
                    // Center text when no icons
                    Spacer()
                }
            }
            .padding(.horizontal, Metrics.horizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.height)
            .background(backgroundView)
            .cornerRadius(CornerRadius.xl)
        }
        .disabled(isInactive)
        .opacity(buttonOpacity)
        .buttonStyle(PrimaryButtonPressStyle(
            shouldHaveShadow: shouldHaveShadow,
            shadowConfig: shadowConfig,
            pressedScale: PressAnimation.pressedScale,
            pressedYTranslation: PressAnimation.pressedYTranslation,
            pressedShadowRadius: PressAnimation.pressedShadowRadius,
            pressedShadowY: PressAnimation.pressedShadowY,
            animation: PressAnimation.animation,
            isInteractive: !isInactive
        ))
    }
    
    @ViewBuilder
    private var leftIcon: some View {
        if let icon = icon {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                .foregroundColor(textColor)
        } else if let iconSystemNameLeft = iconSystemNameLeft {
            Image(systemName: iconSystemNameLeft)
                .font(.system(size: Metrics.systemIconSize, weight: .semibold))
                .foregroundColor(textColor)
        }
    }
    
    @ViewBuilder
    private var rightIcon: some View {
        if let iconSystemNameRight = iconSystemNameRight {
            Image(systemName: iconSystemNameRight)
                .font(.system(size: Metrics.systemIconSize, weight: .medium))
                .foregroundColor(textColor)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            if isInactive {
                disabledAccentBackground(Color.gradientOrangePink)
            } else {
                Color.gradientOrangePink
            }
        case .solid(let color):
            if isInactive {
                disabledAccentBackground(color)
            } else {
                color
            }
        case .outlined:
            Color.clear
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(Color.border, lineWidth: 1)
                )
        case .secondary:
            Color.gray100
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(Color.border, lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private func disabledAccentBackground<Content: View>(_ base: Content) -> some View {
        ZStack {
            base
            Color.white.opacity(DisabledAppearance.overlayOpacity)
        }
    }
}

// MARK: - Custom Button Style for Press Animation
private struct PrimaryButtonPressStyle: ButtonStyle {
    let shouldHaveShadow: Bool
    let shadowConfig: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)
    let pressedScale: CGFloat
    let pressedYTranslation: CGFloat
    let pressedShadowRadius: CGFloat
    let pressedShadowY: CGFloat
    let animation: SwiftUI.Animation
    let isInteractive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && isInteractive
        
        return configuration.label
            .scaleEffect(isPressed ? pressedScale : 1.0)
            .offset(y: isPressed ? pressedYTranslation : 0)
            .shadow(
                color: shouldHaveShadow ? shadowConfig.color : .clear,
                radius: isPressed && shouldHaveShadow ? pressedShadowRadius : (shouldHaveShadow ? shadowConfig.radius : 0),
                x: shouldHaveShadow ? shadowConfig.x : 0,
                y: isPressed && shouldHaveShadow ? pressedShadowY : (shouldHaveShadow ? shadowConfig.y : 0)
            )
            .animation(animation, value: isPressed)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            // Filled style (default)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Filled Style")
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
                
                PrimaryButton(
                    title: "Log In",
                    action: {}
                )
                
                PrimaryButton(
                    title: "Create Account",
                    action: {}
                )
            }
            
            // Outlined style
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Outlined Style")
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
                
                PrimaryButton(
                    title: "Continue with Google",
                    action: {},
                    icon: Image("GoogleIcon"),
                    style: .outlined
                )
            }
            
            // Solid color style with system icons
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Solid Color Style")
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
                
                PrimaryButton(
                    title: "Mark Day 15 Complete",
                    action: {},
                    iconSystemNameLeft: "checkmark",
                    style: .solid(.accentSkyBlue)
                )
                
                PrimaryButton(
                    title: "Start Challenge",
                    action: {},
                    iconSystemNameLeft: "plus",
                    style: .solid(.accentFreshGreen)
                )
                
                PrimaryButton(
                    title: "Get Started",
                    action: {},
                    iconSystemNameRight: "chevron.right",
                    style: .solid(.accentSunsetOrange)
                )
            }
            
            // Secondary style
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Secondary Style")
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
                
                PrimaryButton(
                    title: "Log Out",
                    action: {},
                    iconSystemNameLeft: "arrow.right.square",
                    style: .secondary
                )
            }
            
            // States
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("States")
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
                
                PrimaryButton(
                    title: "Disabled Button",
                    action: {},
                    isEnabled: false
                )
                
                PrimaryButton(
                    title: "Loading Button",
                    action: {},
                    isLoading: true
                )
            }
        }
        .padding()
    }
    .background(Color.background)
}
