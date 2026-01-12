//
//  LoginView.swift
//  100DaysChallenge
//
//  Login screen
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Welcome Back")
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)
                    
                    Text("Continue your journey")
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl)
                
                VStack(spacing: Spacing.xl) {
                    // Email field
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Email")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray400)
                                .frame(width: 20)
                            
                            TextField("your@email.com", text: $viewModel.email)
                                .textFieldStyle(.plain)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.body)
                        }
                        .padding(Spacing.lg)
                        .background(Color.inputBackground)
                        .cornerRadius(CornerRadius.xl)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.xl)
                                .stroke(Color.border, lineWidth: 1)
                        )
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Password")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray400)
                                .frame(width: 20)
                            
                            SecureField("Your password", text: $viewModel.password)
                                .textFieldStyle(.plain)
                                .font(.body)
                        }
                        .padding(Spacing.lg)
                        .background(Color.inputBackground)
                        .cornerRadius(CornerRadius.xl)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.xl)
                                .stroke(Color.border, lineWidth: 1)
                        )
                    }
                    
                    // Forgot password
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Text("Forgot password?")
                                .font(.labelSmall)
                                .foregroundColor(.accentSkyBlue)
                        }
                    }
                    
                    // Login button
                    Button(action: {
                        viewModel.login {
                            appState.handleLoginComplete()
                        }
                    }) {
                        Text("Log In")
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
                    .disabled(!viewModel.isValid)
                    .opacity(viewModel.isValid ? 1 : 0.5)
                }
                
                // Sign up link
                HStack {
                    Text("Don't have an account?")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                    
                    Button(action: {
                        appState.currentScreen = .signUp
                    }) {
                        Text("Sign up")
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
    }
}

