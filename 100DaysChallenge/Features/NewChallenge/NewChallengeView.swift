//
//  NewChallengeView.swift
//  100DaysChallenge
//
//  New challenge creation screen
//

import SwiftUI

struct NewChallengeView: View {
    @EnvironmentObject var challengeStore: ChallengeStore
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = NewChallengeViewModel()
    @State private var showingMaxChallengesAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("New Challenge")
                        .font(.heading1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Start a new 100-day habit journey")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xl)
                
                VStack(spacing: Spacing.xxxl) {
                    // Title input
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("What do you want to achieve?")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                        
                        TextField("e.g. Daily Reading, Morning Yoga", text: $viewModel.title)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .padding(Spacing.lg)
                            .background(Color.inputBackground)
                            .cornerRadius(CornerRadius.xl)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.xl)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                        
                        Text("Choose something meaningful you want to do every day")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Pick a color")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 4), spacing: Spacing.md) {
                            ForEach(ChallengeAccentColor.all, id: \.name) { colorOption in
                                ColorOptionButton(
                                    color: colorOption.color,
                                    isSelected: viewModel.selectedColor == colorOption.color,
                                    onSelect: {
                                        viewModel.selectedColor = colorOption.color
                                    }
                                )
                            }
                        }
                    }
                    
                    // Start challenge button
                    PrimaryButton(
                        title: "Start Challenge",
                        action: {
                            if challengeStore.challenges.count >= 3 {
                                showingMaxChallengesAlert = true
                            } else {
                                let challenge = Challenge(
                                    title: viewModel.title.trimmingCharacters(in: .whitespaces),
                                    accentColor: viewModel.selectedColorHex,
                                    startDate: Date()
                                )
                                
                                if challengeStore.addChallenge(challenge) {
                                    viewModel.reset()
                                    appState.selectedChallengeId = challenge.id
                                    appState.currentTab = .progress
                                }
                            }
                        },
                        iconSystemNameLeft: "plus",
                        style: .solid(viewModel.selectedColor),
                        isEnabled: viewModel.isValid
                    )
                    
                    // Tips card
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("💡 Tips for Success")
                            .font(.label)
                            .foregroundColor(.textPrimary)
                        
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            TipRow(text: "Choose a realistic daily habit")
                            TipRow(text: "Be specific about what counts as \"done\"")
                            TipRow(text: "Pick a time of day that works best")
                            TipRow(text: "You can run up to 3 challenges at once")
                        }
                    }
                    .padding(Spacing.xl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FFF7ED"), Color(hex: "#FDF2F8")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(CornerRadius.xxl)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
        .background(Color.background)
        .alert("Maximum Challenges Reached", isPresented: $showingMaxChallengesAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can have up to 3 active challenges at once. Please complete or delete an existing challenge first.")
        }
    }
}

struct ColorOptionButton: View {
    let color: Color
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .fill(color)
                    .frame(height: 80)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 12, x: 0, y: 4)
                
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                        
                        Circle()
                            .fill(color)
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Text("•")
                .font(.body)
                .foregroundColor(.textSecondary)
            
            Text(text)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
        }
    }
}

