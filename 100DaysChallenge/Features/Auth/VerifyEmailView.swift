//
//  VerifyEmailView.swift
//  100DaysChallenge
//
//  Email verification screen shown when user is authenticated but email is not verified
//

import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(LocalizedStrings.Auth.verifyEmailTitle)
                        .font(.displaySmall)
                        .foregroundColor(.textPrimary)
                    
                    Text(LocalizedStrings.Auth.verifyEmailMessage)
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl)
                
                VStack(spacing: Spacing.xl) {
                    // Resend email button
                    PrimaryButton(
                        title: authViewModel.resendCooldownSeconds > 0 
                            ? LocalizedStrings.Auth.resendVerificationEmailWithCooldown(authViewModel.resendCooldownSeconds)
                            : LocalizedStrings.Auth.resendVerificationEmail,
                        action: {
                            authViewModel.sendEmailVerification()
                        },
                        isEnabled: authViewModel.resendCooldownSeconds == 0 && !authViewModel.isLoading,
                        isLoading: authViewModel.isLoading
                    )
                    
                    // Refresh button
                    PrimaryButton(
                        title: LocalizedStrings.Auth.iVerifiedRefresh,
                        action: {
                            Task {
                                await authViewModel.reloadUser()
                            }
                        },
                        isEnabled: true,
                        isLoading: false
                    )
                    
                    // Log out button
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text(LocalizedStrings.Auth.logOut)
                            .font(.label)
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
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
            resetPrompt: .constant(nil)
        )
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await authViewModel.reloadUser()
                }
            }
        }
    }
}

#Preview {
    VerifyEmailView()
        .environmentObject(AuthViewModel())
}
