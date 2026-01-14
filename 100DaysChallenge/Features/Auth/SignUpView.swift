//
//  SignUpView.swift
//  100DaysChallenge
//
//  Sign up screen
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Create Account")
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)
                    
                    Text("Start your journey to building lasting habits")
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl)
                
                VStack(spacing: Spacing.xl) {
                    // Name field
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Name")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                        
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.gray400)
                                .frame(width: 20)
                            
                            TextField("Your name", text: $viewModel.name)
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
                            
                            SecureField("Create a password", text: $viewModel.password)
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
                    
                    // Sign up button
                    Button(action: {
                        viewModel.signUp {
                            appState.handleSignUpComplete()
                        }
                    }) {
                        Text("Create Account")
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
                
                // Login link
                HStack {
                    Text("Already have an account?")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                    
                    Button(action: {
                        appState.currentScreen = .login
                    }) {
                        Text("Log in")
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

#Preview {
    SignUpView()
        .environmentObject(AppState())
}

