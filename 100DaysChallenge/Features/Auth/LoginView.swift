//
//  LoginView.swift
//  100DaysChallenge
//
//  Login screen
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var didSubmit = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(LocalizedStrings.Auth.welcomeBack)
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)
                    
                    Text(LocalizedStrings.Auth.continueJourney)
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl)
                
                VStack(spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        InputField(
                            label: LocalizedStrings.Auth.email,
                            placeholder: LocalizedStrings.Auth.emailPlaceholder,
                            text: $authViewModel.email,
                            type: .email,
                            iconName: "envelope"
                        )
                        .onChange(of: authViewModel.email) { _ in
                            if didSubmit {
                                _ = authViewModel.validateLoginForm()
                            }
                        }
                        
                        if didSubmit, let emailError = authViewModel.emailError {
                            Text(emailError)
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Spacing.sm)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        InputField(
                            label: LocalizedStrings.Auth.password,
                            placeholder: LocalizedStrings.Auth.passwordPlaceholderLogin,
                            text: $authViewModel.password,
                            type: .password,
                            iconName: "lock"
                        )
                        .onChange(of: authViewModel.password) { _ in
                            if didSubmit {
                                _ = authViewModel.validateLoginForm()
                            }
                        }
                        
                        if didSubmit, let passwordError = authViewModel.passwordError {
                            Text(passwordError)
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Spacing.sm)
                        }
                    }
                    
                    // Forgot password
                    HStack {
                        Spacer()
                        Button(action: {
                            authViewModel.resetPassword()
                        }) {
                            Text(LocalizedStrings.Auth.forgotPassword)
                                .font(.labelSmall)
                                .foregroundColor(.accentSkyBlue)
                        }
                    }
                    
                    // Login button
                    Button(action: {
                        didSubmit = true
                        guard authViewModel.validateLoginForm() else { return }
                        authViewModel.signIn {
                            appState.handleLoginComplete()
                        }
                    }) {
                        Text(LocalizedStrings.Auth.logInButton)
                            .font(.label)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color.gradientOrangePinkStart, Color.gradientOrangePinkEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(CornerRadius.xl)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty)
                    .opacity(authViewModel.email.isEmpty || authViewModel.password.isEmpty ? 0.5 : 1)
                }
                
                // Sign up link
                HStack {
                    Text(LocalizedStrings.Auth.dontHaveAccount)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                    
                    Button(action: {
                        appState.currentScreen = .signUp
                    }) {
                        Text(LocalizedStrings.Auth.signUp)
                            .font(.label)
                            .foregroundColor(.accentSkyBlue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.xl)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color.background)
        .messageAlert(error: $authViewModel.errorMessage, info: $authViewModel.infoMessage)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
}

