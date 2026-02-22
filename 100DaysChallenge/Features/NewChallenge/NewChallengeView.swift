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

    private var titleBinding: Binding<String> {
        Binding(
            get: { viewModel.title },
            set: { viewModel.setTitle($0) }
        )
    }

    private var alertPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alert != nil },
            set: { if !$0 { viewModel.dismissAlert() } }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // Title input
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text(LocalizedStrings.NewChallenge.whatDoYouWantToAchieve.uppercased())
                                .sectionHeaderStyle()

                            TextField(LocalizedStrings.NewChallenge.placeholder, text: titleBinding)
                                .textFieldStyle(.plain)
                                .font(.body)
                                .padding(Spacing.lg)
                                .background(Color.inputBackground)
                                .cornerRadius(CornerRadius.xl)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.xl)
                                        .stroke(Color.border, lineWidth: 1)
                                )
                        }

                        // Quick ideas
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text(LocalizedStrings.NewChallenge.quickIdeas.uppercased())
                                .sectionHeaderStyle()

                            FlowLayout(horizontalSpacing: Spacing.sm, verticalSpacing: Spacing.sm) {
                                ForEach(LocalizedStrings.NewChallenge.Tags.all, id: \.self) { tag in
                                    ChipTagView(tag: tag, onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.setTitle(tag)
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
                                ForEach(Array(ChallengeAccentColor.all.enumerated()), id: \.element.name) { index, colorOption in
                                    ColorOptionButton(
                                        color: colorOption.color,
                                        isSelected: viewModel.selectedColorIndex == index,
                                        onSelect: {
                                            viewModel.selectColor(index)
                                        }
                                    )
                                }
                            }
                        }

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
                    .padding(.top, Spacing.lg)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, BottomActionBarLayout.scrollContentBottomMargin)
                }
                .contentMargins(.bottom, BottomActionBarLayout.scrollContentBottomMargin, for: .scrollContent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                BottomActionBar {
                    PrimaryButton(
                        title: LocalizedStrings.NewChallenge.startChallenge,
                        action: { viewModel.submit() },
                        iconSystemNameLeft: "plus",
                        style: .solid(viewModel.selectedColor),
                        isEnabled: viewModel.isSubmitEnabled,
                        isLoading: viewModel.isLoading
                    )
                }
            }
            .background(Color.background)
            .navigationTitle(LocalizedStrings.NewChallenge.title)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.onAppear(challengeStore: challengeStore, appState: appState)
            }
        }
        .alert(viewModel.alertTitle, isPresented: alertPresentedBinding) {
            Button(LocalizedStrings.NewChallenge.ok, role: .cancel) {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage)
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

