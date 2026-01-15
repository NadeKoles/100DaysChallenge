//
//  SignUpView.swift
//  100DaysChallenge
//
//  Sign up screen
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var didSubmit = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(LocalizedStrings.Auth.createAccount)
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)
                    
                    Text(LocalizedStrings.Auth.startJourney)
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl)
                
                VStack(spacing: Spacing.xl) {
                    InputField(
                        label: LocalizedStrings.Auth.name,
                        placeholder: LocalizedStrings.Auth.namePlaceholder,
                        text: $authViewModel.name,
                        type: .text,
                        iconName: "person"
                    )
                    
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
                                _ = authViewModel.validateSignUpForm()
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
                            placeholder: LocalizedStrings.Auth.passwordPlaceholder,
                            text: $authViewModel.password,
                            type: .password,
                            iconName: "lock"
                        )
                        .onChange(of: authViewModel.password) { _ in
                            if didSubmit {
                                _ = authViewModel.validateSignUpForm()
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
                    
                    // Sign up button
                    Button(action: {
                        didSubmit = true
                        guard authViewModel.validateSignUpForm() else { return }
                        authViewModel.signUp {
                            appState.handleSignUpComplete()
                        }
                    }) {
                        Text(LocalizedStrings.Auth.createAccountButton)
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
                    .disabled(authViewModel.name.isEmpty ||
                             authViewModel.email.isEmpty ||
                             authViewModel.password.isEmpty)
                    .opacity(authViewModel.name.isEmpty ||
                            authViewModel.email.isEmpty ||
                            authViewModel.password.isEmpty ? 0.5 : 1)
                }
                
                // Login link
                HStack {
                    Text(LocalizedStrings.Auth.alreadyHaveAccount)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                    
                    Button(action: {
                        appState.currentScreen = .login
                    }) {
                        Text(LocalizedStrings.Auth.logIn)
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
        .onAppear {
            authViewModel.resetFormState()
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
}

