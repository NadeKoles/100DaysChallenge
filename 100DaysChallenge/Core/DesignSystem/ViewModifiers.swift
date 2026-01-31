//
//  ViewModifiers.swift
//  100DaysChallenge
//
//  Reusable view modifiers for consistent styling
//

import SwiftUI

// MARK: - Bottom Action Bar (sticky bar)
enum BottomActionBarLayout {
    static let scrollContentBottomMargin: CGFloat = 80
}

struct BottomActionBar<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(0.06), radius: 12, y: -2)
    }
}

// MARK: - Reset Password Prompt Model
struct ResetPasswordPrompt: Identifiable, Equatable {
    let id = UUID()
    var email: String
    var onSend: (String) -> Void
    
    // Compare id and email, ignore closure
    static func == (lhs: ResetPasswordPrompt, rhs: ResetPasswordPrompt) -> Bool {
        lhs.id == rhs.id && lhs.email == rhs.email
    }
}

extension View {
    // MARK: - Unified Auth Alerts
    func authAlerts(
        error: Binding<String?>,
        info: Binding<String?>,
        resetPrompt: Binding<ResetPasswordPrompt?>
    ) -> some View {
        self.modifier(AuthAlertsModifier(
            error: error,
            info: info,
            resetPrompt: resetPrompt
        ))
    }
    
    // MARK: - Section Header Style
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyleModifier())
    }
}

// MARK: - Section Header Style Modifier
private struct SectionHeaderStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.labelTiny)
            .foregroundColor(.textTertiary)
            .tracking(1)
    }
}

// MARK: - Auth Alerts Modifier
private struct AuthAlertsModifier: ViewModifier {
    @Binding var error: String?
    @Binding var info: String?
    @Binding var resetPrompt: ResetPasswordPrompt?
    @State private var resetEmail: String = ""
    @State private var resetEmailError: String?
    @State private var shouldReopenResetPrompt = false
    
    private var isAlertPresented: Bool {
        resetPrompt != nil || error != nil || info != nil
    }
    
    private var alertTitle: String {
        if resetPrompt != nil {
            return LocalizedStrings.Auth.resetPasswordTitle
        } else if error != nil {
            return LocalizedStrings.Auth.errorTitle
        } else {
            return LocalizedStrings.Auth.infoTitle
        }
    }
    
    private var trimmedResetEmail: String {
        resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    func body(content: Content) -> some View {
        content
            .alert(
                alertTitle,
                isPresented: Binding(
                    get: { isAlertPresented },
                    set: { newValue in
                        if !newValue {
                            if shouldReopenResetPrompt && resetPrompt != nil {
                                // Reopen prompt after validation failure
                                if let currentPrompt = resetPrompt {
                                    Task { @MainActor in
                                        resetPrompt = nil
                                        await Task.yield()

                                        resetPrompt = ResetPasswordPrompt(
                                            email: currentPrompt.email,
                                            onSend: currentPrompt.onSend
                                        )
                                        shouldReopenResetPrompt = false
                                    }
                                }
                            } else {
                                resetPrompt = nil
                                error = nil
                                info = nil
                            }
                        }
                    }
                )
            ) {
                if resetPrompt != nil {
                    TextField(LocalizedStrings.Auth.emailPlaceholder, text: $resetEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: resetEmail) {
                            resetEmailError = nil
                        }
                    
                    Button(LocalizedStrings.Auth.cancel, role: .cancel) {
                        resetPrompt = nil
                        resetEmailError = nil
                        shouldReopenResetPrompt = false
                    }
                    
                    Button(LocalizedStrings.Auth.send) {
                        guard let prompt = resetPrompt else { return }
                        
                        let normalized = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        guard !normalized.isEmpty else {
                            return
                        }
                        
                        guard AuthViewModel.isValidEmail(normalized) else {
                            resetEmailError = LocalizedStrings.Auth.invalidEmail
                            shouldReopenResetPrompt = true
                            return
                        }
                        
                        resetEmailError = nil
                        shouldReopenResetPrompt = false
                        prompt.onSend(normalized)
                        resetPrompt = nil
                    }
                    .disabled(trimmedResetEmail.isEmpty)
                } else {
                    Button(LocalizedStrings.Auth.ok) {
                        error = nil
                        info = nil
                    }
                }
            } message: {
                if resetPrompt != nil {
                    if let resetEmailError = resetEmailError {
                        Text(resetEmailError)
                            .foregroundStyle(.red)
                            .font(.callout)
                    } else {
                        Text(LocalizedStrings.Auth.resetPasswordMessage)
                    }
                } else if let errorMessage = error {
                    Text(errorMessage)
                } else if let infoMessage = info {
                    Text(infoMessage)
                }
            }
            .onChange(of: resetPrompt) { _, newValue in
                if let prompt = newValue {
                    // Preserve error state when reopening after validation failure
                    if resetEmailError == nil {
                        resetEmail = prompt.email
                        resetEmailError = nil
                        shouldReopenResetPrompt = false
                    }
                } else {
                    resetEmail = ""
                    resetEmailError = nil
                    shouldReopenResetPrompt = false
                }
            }
    }
}
