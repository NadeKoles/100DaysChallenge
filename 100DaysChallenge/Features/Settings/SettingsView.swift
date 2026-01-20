//
//  SettingsView.swift
//  100DaysChallenge
//
//  Settings screen
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var challengeStore: ChallengeStore
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SettingsViewModel()
    @State private var challengeToDelete: Challenge? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Settings")
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                    .padding(.top, Spacing.xxxl)
                    .padding(.bottom, Spacing.xl)
                
                // Account section
                SettingsSection(title: "ACCOUNT") {
                    SettingsRow(icon: "person", title: "Profile") { }
                    SettingsRow(icon: "bell", title: "Notifications") { }
                }
                
                // Challenges section
                if !challengeStore.challenges.isEmpty {
                    SettingsSection(title: "YOUR CHALLENGES") {
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
                SettingsSection(title: "SUPPORT") {
                    SettingsRow(icon: "questionmark.circle", title: "Help Center") { }
                    SettingsRow(icon: "shield", title: "Privacy Policy") { }
                }
                
                // Logout button
                PrimaryButton(
                    title: "Log Out",
                    action: {
                        appState.handleLogout()
                    },
                    iconSystemNameLeft: "arrow.right.square",
                    style: .secondary
                )
                .padding(.top, Spacing.xl)
                
                // Version
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.xl)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color.background)
        .alert("Delete Challenge?", isPresented: Binding(
            get: { challengeToDelete != nil },
            set: { if !$0 { challengeToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                challengeToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let challenge = challengeToDelete {
                    challengeStore.deleteChallenge(id: challenge.id)
                    challengeToDelete = nil
                }
            }
        } message: {
            if let challenge = challengeToDelete {
                Text("This will permanently delete \"\(challenge.title)\" and all progress. This action cannot be undone.")
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
                
                Text("\(challenge.completedDaysSet.count) / 100 days")
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

