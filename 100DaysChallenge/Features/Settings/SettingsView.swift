//
//  SettingsView.swift
//  100DaysChallenge
//
//  Settings screen
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var challengeStore: ChallengeStore
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @State private var challengeToDelete: Challenge? = nil

    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Account section
            SettingsSection(title: LocalizedStrings.Settings.accountSection) {
                SettingsRow(icon: "person", title: LocalizedStrings.Settings.profile) { }
                SettingsRow(icon: "bell", title: LocalizedStrings.Settings.notifications) { }
            }

            // Challenges section
            if !challengeStore.challenges.isEmpty {
                SettingsSection(title: LocalizedStrings.Settings.yourChallengesSection) {
                    ForEach(challengeStore.challenges) { challenge in
                        ChallengeRow(
                            challenge: challenge,
                            onDelete: {
                                challengeToDelete = challenge
                            }
                        )
                    }
                }
            }

            // Support section
            SettingsSection(title: LocalizedStrings.Settings.supportSection) {
                SettingsRow(icon: "questionmark.circle", title: LocalizedStrings.Settings.helpCenter) { }
                SettingsRow(icon: "shield", title: LocalizedStrings.Settings.privacyPolicy) { }
            }

            // Log out + version footer
            VStack(spacing: 0) {
                PrimaryButton(
                    title: LocalizedStrings.Auth.logOut,
                    action: {
                        authViewModel.signOut()
                    },
                    iconSystemNameLeft: "arrow.right.square",
                    style: .secondary
                )
                Text(LocalizedStrings.Settings.version("1.0.0"))
                    .font(.footnote)
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.md)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Spacing.xl)
        }
        .padding(.top, Spacing.lg)
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.lg)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                settingsContent
            }
            .background(Color.background)
            .navigationTitle(LocalizedStrings.Settings.title)
            .navigationBarTitleDisplayMode(.large)
        }
        .alert(LocalizedStrings.Settings.deleteChallengeTitle, isPresented: Binding(
            get: { challengeToDelete != nil },
            set: { if !$0 { challengeToDelete = nil } }
        )) {
            Button(LocalizedStrings.Progress.cancel, role: .cancel) {
                challengeToDelete = nil
            }
            Button(LocalizedStrings.Settings.delete, role: .destructive) {
                if let challenge = challengeToDelete {
                    challengeStore.deleteChallenge(id: challenge.id)
                    challengeToDelete = nil
                }
            }
        } message: {
            if let challenge = challengeToDelete {
                Text(LocalizedStrings.Settings.deleteChallengeMessage(challenge.title))
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .sectionHeaderStyle()
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.background)
            .cornerRadius(CornerRadius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.textSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(Spacing.lg)
        }
        .buttonStyle(.plain)
    }
}

struct ChallengeRow: View {
    let challenge: Challenge
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Color indicator
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color(hex: challenge.accentColor).opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Text("\(challenge.completedDaysSet.count)")
                    .font(.label)
                    .foregroundColor(Color(hex: challenge.accentColor))
            }
            
            // Challenge info
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(LocalizedStrings.Settings.challengeProgress(challenge.completedDaysSet.count))
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.accentCoralRed)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(Spacing.lg)
    }
}

#Preview("1 Challenge") {
    let store = ChallengeStore.previewWithOneChallenge()
    let authViewModel = AuthViewModel()
    let appState = AppState(authViewModel: authViewModel)
    appState.currentTab = .settings

    return MainTabView()
        .environmentObject(store)
        .environmentObject(appState)
        .environmentObject(authViewModel)
}
