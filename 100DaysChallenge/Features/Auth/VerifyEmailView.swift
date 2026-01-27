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
                    PrimaryButton(
                        title: authViewModel.resendVerificationButtonTitle,
                        action: { authViewModel.sendEmailVerification() },
                        isEnabled: authViewModel.resendCooldownSeconds == 0 && !authViewModel.isLoading,
                        isLoading: authViewModel.isLoading
                    )

                    PrimaryButton(
                        title: LocalizedStrings.Auth.iVerifiedRefresh,
                        action: { Task { await authViewModel.checkVerification() } },
                        isEnabled: !authViewModel.isRefreshing,
                        isLoading: authViewModel.isRefreshing
                    )

                    PrimaryButton(
                        title: LocalizedStrings.Auth.logOut,
                        action: { authViewModel.signOut() },
                        style: .secondary
                    )
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color.background)
        .alert(item: verifyEmailAlertBinding) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text(alert.primaryTitle)) {
                    authViewModel.dismissVerifyEmailAlert()
                }
            )
        }
        .task {
            await authViewModel.checkVerification()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            authViewModel.onVerifyEmailSceneActive()
        }
        .onDisappear {
            authViewModel.onVerifyEmailDisappear()
        }
    }

    private var verifyEmailAlertBinding: Binding<VerifyEmailAlertState?> {
        Binding(
            get: { authViewModel.verifyEmailAlert },
            set: { _ in authViewModel.dismissVerifyEmailAlert() }
        )
    }
}

#Preview {
    VerifyEmailView()
        .environmentObject(AuthViewModel())
}
