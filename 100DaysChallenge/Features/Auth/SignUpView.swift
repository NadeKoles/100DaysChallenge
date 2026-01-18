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
    @State private var resetPrompt: ResetPasswordPrompt? = nil
    
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
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        InputField(
                            label: LocalizedStrings.Auth.name,
                            placeholder: LocalizedStrings.Auth.namePlaceholder,
                            text: $authViewModel.name,
                            type: .text,
                            iconName: "person"
                        )
                        .onChange(of: authViewModel.name) { _ in
                            authViewModel.clearFormError()
                            if didSubmit {
                                _ = authViewModel.validateSignUpForm()
                            }
                        }
                        
                        if didSubmit, let nameError = authViewModel.nameError {
                            Text(nameError)
                                .font(.caption)
                                .foregroundStyle(Color.textError)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Spacing.sm)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        InputField(
                            label: LocalizedStrings.Auth.email,
                            placeholder: LocalizedStrings.Auth.emailPlaceholder,
                            text: $authViewModel.email,
                            type: .email,
                            iconName: "envelope"
                        )
                        .onChange(of: authViewModel.email) { _ in
                            authViewModel.clearFormError()
                            if didSubmit {
                                _ = authViewModel.validateSignUpForm()
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
                            placeholder: LocalizedStrings.Auth.passwordPlaceholder,
                            text: $authViewModel.password,
                            type: .password,
                            iconName: "lock"
                        )
                        .onChange(of: authViewModel.password) { _ in
                            authViewModel.clearFormError()
                            if didSubmit {
                                _ = authViewModel.validateSignUpForm()
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
                    }
                    
                    VStack(spacing: Spacing.sm) {
                        // Sign up button
                        PrimaryButton(
                            title: LocalizedStrings.Auth.createAccountButton,
                            action: {
                                didSubmit = true
                                guard authViewModel.validateSignUpForm() else { return }
                                authViewModel.signUp {
                                    appState.handleSignUpComplete()
                                }
                            },
                            isEnabled: !authViewModel.name.isEmpty &&
                                      !authViewModel.email.isEmpty &&
                                      !authViewModel.password.isEmpty,
                            isLoading: authViewModel.isLoading
                        )
                        
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
    SignUpView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
}

