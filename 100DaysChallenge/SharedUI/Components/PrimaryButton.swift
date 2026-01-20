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
        static let systemIconSizeLeft: CGFloat = 20
        static let systemIconSizeRight: CGFloat = 16
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
        (isEnabled && !isLoading) ? 1 : 0.5
    }
    
    private var shadowConfig: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        let opacity: Double
        switch style {
        case .outlined, .secondary:
            opacity = 0.08
        case .filled, .solid:
            opacity = 0.1
        }
        return (color: .black.opacity(opacity), radius: 8, x: 0, y: 4)
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
            .shadow(
                color: shadowConfig.color,
                radius: shadowConfig.radius,
                x: shadowConfig.x,
                y: shadowConfig.y
            )
        }
        .disabled(!isEnabled || isLoading)
        .opacity(buttonOpacity)
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
                .font(.system(size: Metrics.systemIconSizeLeft, weight: .semibold))
                .foregroundColor(textColor)
        }
    }
    
    @ViewBuilder
    private var rightIcon: some View {
        if let iconSystemNameRight = iconSystemNameRight {
            Image(systemName: iconSystemNameRight)
                .font(.system(size: Metrics.systemIconSizeRight, weight: .medium))
                .foregroundColor(textColor)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            Color.gradientOrangePink
        case .solid(let color):
            color
        case .outlined:
            Color.clear
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(Color.border, lineWidth: 1)
                )
        case .secondary:
            Color.gray100
        }
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
