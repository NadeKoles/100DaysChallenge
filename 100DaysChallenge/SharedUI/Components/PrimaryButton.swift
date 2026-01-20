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
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [Color.gradientOrangePinkStart, Color.gradientOrangePinkEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
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
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                leftIcon
                Text(title)
                    .font(.label)
                    .foregroundColor(textColor)
                rightIcon
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundView)
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
                .frame(width: 25, height: 25)
                .foregroundColor(textColor)
        } else if let iconSystemNameLeft = iconSystemNameLeft {
            Image(systemName: iconSystemNameLeft)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
        }
    }
    
    @ViewBuilder
    private var rightIcon: some View {
        if let iconSystemNameRight = iconSystemNameRight {
            Image(systemName: iconSystemNameRight)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor)
        }
    }
    
    private func applyButtonStyling(to view: some View) -> some View {
        view
            .cornerRadius(CornerRadius.xl)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            applyButtonStyling(to: gradient)
        case .solid(let color):
            applyButtonStyling(to: color)
        case .outlined:
            Color.clear
                .cornerRadius(CornerRadius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(Color.border, lineWidth: 1)
                )
        case .secondary:
            Color.gray100
                .cornerRadius(CornerRadius.xl)
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
