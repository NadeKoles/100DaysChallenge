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
    @State private var resetPrompt: ResetPasswordPrompt? = nil
    
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
                        .onChange(of: authViewModel.email) {
                            authViewModel.clearFormError()
                            if didSubmit {
                                _ = authViewModel.validateLoginForm()
                            }
                        }
                        
                        if didSubmit, let emailError = authViewModel.emailError {
                            Text(emailError)
                                .font(.caption)
                                .foregroundStyle(Color.textError)
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
                        .onChange(of: authViewModel.password) {
                            authViewModel.clearFormError()
                            if didSubmit {
                                _ = authViewModel.validateLoginForm()
                            }
                        }
                        
                        if didSubmit, let passwordError = authViewModel.passwordError {
                            Text(passwordError)
                                .font(.caption)
                                .foregroundStyle(Color.textError)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Spacing.sm)
                        }
                        
                        if let formError = authViewModel.formError {
                            Text(formError)
                                .font(.caption)
                                .foregroundStyle(Color.textError)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Spacing.sm)
                        }
                        
                        // Forgot password
                        HStack {
                            Spacer()
                            Button(action: {
                                resetPrompt = ResetPasswordPrompt(
                                    email: authViewModel.email,
                                    onSend: { email in
                                        authViewModel.resetPassword(email: email)
                                    }
                                )
                            }) {
                                Text(LocalizedStrings.Auth.forgotPassword)
                                    .font(.labelSmall)
                                    .foregroundColor(.accentSkyBlue)
                            }
                        }
                        .padding(.top, Spacing.xxs)
                    }
                    
                    VStack(spacing: Spacing.sm) {
                        // Login button
                        PrimaryButton(
                            title: LocalizedStrings.Auth.logInButton,
                            action: {
                                didSubmit = true
                                guard authViewModel.validateLoginForm() else { return }
                                authViewModel.signIn {
                                    appState.handleLoginComplete()
                                }
                            },
                            isEnabled: !authViewModel.email.isEmpty && !authViewModel.password.isEmpty,
                            isLoading: authViewModel.isLoading
                        )
                        
                        // Divider with "or"
                        HStack(spacing: Spacing.md) {
                            Rectangle()
                                .fill(Color.border)
                                .frame(height: 1)
                            
                            Text(LocalizedStrings.Auth.or)
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                            
                            Rectangle()
                                .fill(Color.border)
                                .frame(height: 1)
                        }
                        .padding(.vertical, Spacing.sm)
                        
                        // Continue with Apple button (hidden until feature flag is enabled)
                        // TODO: Enable Sign in with Apple after enrolling in Apple Developer Program
                        if AuthViewModel.isAppleSignInEnabled {
                            PrimaryButton(
                                title: LocalizedStrings.Auth.continueWithApple,
                                action: {
                                    authViewModel.signInWithApple {
                                        appState.handleLoginComplete()
                                    }
                                },
                                icon: Image("Apple"),
                                style: .outlined,
                                isEnabled: !authViewModel.isLoading,
                                isLoading: authViewModel.isLoading
                            )
                        }
                        
                        // Continue with Google button
                        PrimaryButton(
                            title: LocalizedStrings.Auth.continueWithGoogle,
                            action: {
                                authViewModel.signInWithGoogle {
                                    appState.handleLoginComplete()
                                }
                            },
                            icon: Image("GoogleIcon"),
                            style: .outlined,
                            isEnabled: !authViewModel.isLoading,
                            isLoading: authViewModel.isLoading
                        )
                        
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
                    }
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color.background)
        .authAlerts(
            error: $authViewModel.errorMessage,
            info: $authViewModel.infoMessage,
            resetPrompt: $resetPrompt
        )
        .onAppear {
            didSubmit = false
            authViewModel.resetFormState()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
}

