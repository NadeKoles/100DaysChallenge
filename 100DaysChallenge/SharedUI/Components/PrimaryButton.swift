//
//  PrimaryButton.swift
//  100DaysChallenge
//
//  Reusable primary button component for authentication actions
//

import SwiftUI

struct PrimaryButton: View {
    enum Style {
        case filled
        case outlined
    }
    
    let title: String
    let action: () -> Void
    let icon: Image?
    let style: Style
    let isEnabled: Bool
    let isLoading: Bool
    
    init(
        title: String,
        action: @escaping () -> Void,
        icon: Image? = nil,
        style: Style = .filled,
        isEnabled: Bool = true,
        isLoading: Bool = false
    ) {
        self.title = title
        self.action = action
        self.icon = icon
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
        style == .filled ? .white : .textPrimary
    }
    
    private var iconColor: Color {
        style == .filled ? .white : .textPrimary
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
                
                Text(title)
                    .font(.label)
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundView)
        }
        .disabled(!isEnabled || isLoading)
        .opacity((isEnabled && !isLoading) ? 1 : 0.5)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if style == .filled {
            gradient
                .cornerRadius(CornerRadius.xl)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        } else {
            Color.clear
                .cornerRadius(CornerRadius.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                        .stroke(Color.border, lineWidth: 1)
                )
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        PrimaryButton(
            title: "Log In",
            action: {}
        )
        
        PrimaryButton(
            title: "Create Account",
            action: {}
        )
        
        PrimaryButton(
            title: "Continue with Google",
            action: {},
            icon: Image("GoogleIcon"),
            style: .outlined
        )
        
        PrimaryButton(
            title: "Disabled Button",
            action: {},
            isEnabled: false
        )
    }
    .padding()
}
