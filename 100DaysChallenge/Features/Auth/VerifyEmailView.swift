//
//  VerifyEmailView.swift
//  100DaysChallenge
//
//  Email verification screen shown when user is authenticated but email is not verified
//

import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var reloadTask: Task<Void, Never>?
    @State private var isResending = false
    @State private var isRefreshing = false
    
    private var formattedCooldown: String {
        let seconds = authViewModel.resendCooldownSeconds
        guard seconds > 0 else { return "" }
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return "\(seconds)s"
        }
    }
    
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
                            ? LocalizedStrings.Auth.resendVerificationEmailWithCooldown(formattedCooldown)
                            : LocalizedStrings.Auth.resendVerificationEmail,
                        action: {
                            isResending = true
                            authViewModel.sendEmailVerification()
                            // Fallback: reset if isLoading never becomes true (early return case)
                            Task {
                                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                                if isResending && !authViewModel.isLoading {
                                    isResending = false
                                }
                            }
                        },
                        isEnabled: authViewModel.resendCooldownSeconds == 0 && !isResending,
                        isLoading: isResending
                    )
                    .onChange(of: authViewModel.isLoading) { oldValue, newValue in
                        if isResending && !newValue {
                            isResending = false
                        }
                    }
                    
                    // Refresh button
                    PrimaryButton(
                        title: LocalizedStrings.Auth.iVerifiedRefresh,
                        action: {
                            Task {
                                isRefreshing = true
                                await authViewModel.reloadUser()
                                isRefreshing = false
                            }
                        },
                        isEnabled: !isRefreshing,
                        isLoading: isRefreshing
                    )
                    
                    // Log out button
                    PrimaryButton(
                        title: LocalizedStrings.Auth.logOut,
                        action: {
                            authViewModel.signOut()
                        },
                        style: .secondary
                    )
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color.background)
        .authAlerts(
            error: $authViewModel.errorMessage,
            info: $authViewModel.infoMessage,
            resetPrompt: .constant(nil)
        )
        .task {
            isRefreshing = true
            await authViewModel.reloadUser()
            isRefreshing = false
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            reloadTask?.cancel()
            reloadTask = Task {
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard !Task.isCancelled else { return }
                isRefreshing = true
                await authViewModel.reloadUser()
                isRefreshing = false
            }
        }
        .onDisappear {
            reloadTask?.cancel()
            isRefreshing = false
            isResending = false
        }
    }
}

#Preview {
    VerifyEmailView()
        .environmentObject(AuthViewModel())
}
