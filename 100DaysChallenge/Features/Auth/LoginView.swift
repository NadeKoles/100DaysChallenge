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
                    InputField(
                        label: LocalizedStrings.Auth.email,
                        placeholder: LocalizedStrings.Auth.emailPlaceholder,
                        text: $authViewModel.email,
                        type: .email,
                        iconName: "envelope"
                    )
                    
                    InputField(
                        label: LocalizedStrings.Auth.password,
                        placeholder: LocalizedStrings.Auth.passwordPlaceholderLogin,
                        text: $authViewModel.password,
                        type: .password,
                        iconName: "lock"
                    )
                    
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
                    .disabled(!authViewModel.isValidForLogin)
                    .opacity(authViewModel.isValidForLogin ? 1 : 0.5)
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

