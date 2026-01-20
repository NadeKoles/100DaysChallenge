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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(LocalizedStrings.NewChallenge.subtitle)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.bottom, Spacing.xl)
                
                VStack(spacing: Spacing.xxxl) {
                    // Title input
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text(LocalizedStrings.NewChallenge.whatDoYouWantToAchieve.uppercased())
                            .sectionHeaderStyle()
                        
                        TextField(LocalizedStrings.NewChallenge.titlePlaceholder, text: $viewModel.title)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .padding(Spacing.lg)
                            .background(Color.inputBackground)
                            .cornerRadius(CornerRadius.xl)
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.xl)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                        
                        Text(LocalizedStrings.NewChallenge.helperText)
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                    
                    // Quick ideas
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text(LocalizedStrings.NewChallenge.quickIdeas.uppercased())
                            .sectionHeaderStyle()
                        
                        FlowLayout(horizontalSpacing: Spacing.sm, verticalSpacing: Spacing.sm) {
                            ForEach(LocalizedStrings.NewChallenge.Tags.all, id: \.self) { tag in
                                ChipTagView(tag: tag, onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.title = tag
                                    }
                                })
                            }
                        }
                    }
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text(LocalizedStrings.NewChallenge.pickAColor.uppercased())
                            .sectionHeaderStyle()
                        
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
                        title: LocalizedStrings.NewChallenge.startChallenge,
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
                        Text(LocalizedStrings.NewChallenge.tipsForSuccess)
                            .font(.label)
                            .foregroundColor(.textPrimary)
                        
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            TipRow(text: LocalizedStrings.NewChallenge.tipRealisticHabit)
                            TipRow(text: LocalizedStrings.NewChallenge.tipBeSpecific)
                            TipRow(text: LocalizedStrings.NewChallenge.tipPickTime)
                            TipRow(text: LocalizedStrings.NewChallenge.tipMaxChallenges)
                        }
                    }
                    .padding(Spacing.xl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gradientTipsCard)
                    .cornerRadius(CornerRadius.xxl)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
            }
            .background(Color.background)
            .navigationTitle(LocalizedStrings.NewChallenge.title)
            .navigationBarTitleDisplayMode(.large)
        }
        .alert(LocalizedStrings.NewChallenge.maxChallengesReached, isPresented: $showingMaxChallengesAlert) {
            Button(LocalizedStrings.NewChallenge.ok, role: .cancel) { }
        } message: {
            Text(LocalizedStrings.NewChallenge.maxChallengesMessage)
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

private struct ChipTagView: View {
    let tag: String
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Text(tag)
            .font(.labelSmall)
            .foregroundColor(.textSecondary)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .truncationMode(.tail)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.clear)
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.border, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        onTap()
                    }
            )
            .accessibilityLabel(LocalizedStrings.NewChallenge.quickIdeaAccessibilityLabel(tag))
            .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    NewChallengeView()
        .environmentObject(ChallengeStore.shared)
        .environmentObject(AppState())
}

