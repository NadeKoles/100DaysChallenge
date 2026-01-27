//
//  ProgressView.swift
//  100DaysChallenge
//
//  Progress view with 100-day grid and challenge navigation.
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var challengeStore: ChallengeStore
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProgressViewModel()

    var body: some View {
        Group {
            if challengeStore.challenges.isEmpty {
                EmptyChallengesView()
            } else {
                ChallengeProgressView(
                    challenges: challengeStore.challenges,
                    currentIndex: viewModel.currentIndex,
                    onSwipePrevious: { viewModel.previousChallenge() },
                    onSwipeNext: { viewModel.nextChallenge() },
                    onToggleDay: { viewModel.didTapDay($0) },
                    onCompleteToday: { viewModel.markDayComplete(day: $0) }
                )
            }
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.alert != nil },
                set: { if !$0 { viewModel.cancelToggleDay() } }
            )
        ) {
            Button(LocalizedStrings.Progress.cancel, role: .cancel) {
                viewModel.cancelToggleDay()
            }
            if let alert = viewModel.alert {
                Button(alert.primaryButtonTitle) {
                    viewModel.confirmToggleDay()
                }
            }
        } message: {
            if let alert = viewModel.alert {
                Text(alert.message)
            }
        }
        .onAppear {
            viewModel.onAppear(challengeStore: challengeStore, appState: appState)
        }
        .onChange(of: viewModel.currentIndex) {
            viewModel.handleCurrentIndexChanged()
        }
        .onChange(of: challengeStore.challenges) { _, newValue in
            viewModel.handleChallengesUpdated(count: newValue.count)
            viewModel.navigateToSelectedChallengeIfNeeded()
        }
        .onChange(of: appState.selectedChallengeId) {
            viewModel.navigateToSelectedChallengeIfNeeded()
        }
    }
}

struct EmptyChallengesView: View {
    var body: some View {
        ContentUnavailableView {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.gray400)
        } description: {
            VStack(spacing: Spacing.sm) {
                Text(LocalizedStrings.Progress.noChallengesYet)
                    .font(.heading2)
                    .foregroundColor(.textPrimary)

                Text(LocalizedStrings.Progress.noChallengesDescription)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChallengeProgressView: View {
    let challenges: [Challenge]
    let currentIndex: Int
    let onSwipePrevious: () -> Void
    let onSwipeNext: () -> Void
    let onToggleDay: (Int) -> Void
    let onCompleteToday: (Int) -> Void

    private var safeCurrentIndex: Int {
        guard !challenges.isEmpty else { return 0 }
        return max(0, min(currentIndex, challenges.count - 1))
    }

    private var currentChallenge: Challenge? {
        guard safeCurrentIndex >= 0, safeCurrentIndex < challenges.count else {
            return nil
        }
        return challenges[safeCurrentIndex]
    }

    var body: some View {
        Group {
            if let challenge = currentChallenge {
                NavigationStack {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: Spacing.xl) {
                                // Challenge indicator dots
                                HStack(spacing: Spacing.sm) {
                                    ForEach(0..<challenges.count, id: \.self) { index in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(index == safeCurrentIndex ?
                                                  Color(hex: challenge.accentColor) : Color.gray200)
                                            .frame(width: index == safeCurrentIndex ? 24 : 6, height: 6)
                                            .animation(.easeInOut, value: safeCurrentIndex)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, Spacing.xl)
                                .padding(.top, Spacing.xs)

                                // Challenge stats
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                                        Text("\(challenge.completedDaysSet.count)")
                                            .font(.displayMedium)
                                            .foregroundColor(.textPrimary)

                                        Text("/ 100")
                                            .font(.heading3)
                                            .foregroundColor(.textTertiary)
                                    }

                                    Text(LocalizedStrings.Progress.daysCompleted)
                                        .font(.body)
                                        .foregroundColor(.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, Spacing.xl)
                                .padding(.top, Spacing.lg)

                                // Progress bar
                                ProgressBarView(
                                    progress: challenge.progress,
                                    accentColor: Color(hex: challenge.accentColor)
                                )
                                .padding(.horizontal, Spacing.xl)
                                .padding(.bottom, Spacing.lg)

                                // 100-day grid
                                ChallengeGridView(
                                    challenge: challenge,
                                    onToggleDay: onToggleDay
                                )
                                .padding(.horizontal, Spacing.xl)
                                .padding(.bottom, shouldShowButton(challenge) ? 80 : Spacing.xl)
                            }
                        }

                        // Sticky button at bottom
                        if shouldShowButton(challenge) {
                            PrimaryButton(
                                title: LocalizedStrings.Progress.markDayCompleteFormatted(challenge.currentDay),
                                action: { onCompleteToday(challenge.currentDay) },
                                iconSystemNameLeft: "checkmark",
                                style: .solid(Color(hex: challenge.accentColor))
                            )
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.md)
                            .background(Color.background)
                        }
                    }
                    .navigationTitle(challenge.title)
                    .navigationBarTitleDisplayMode(.large)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width > threshold {
                                    onSwipePrevious()
                                } else if value.translation.width < -threshold {
                                    onSwipeNext()
                                }
                            }
                    )
                }
            } else {
                ContentUnavailableView {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.gray400)
                } description: {
                    Text(LocalizedStrings.Progress.noChallengeAvailable)
                        .font(.heading2)
                        .foregroundColor(.textPrimary)
                }
            }
        }
    }

    private func shouldShowButton(_ challenge: Challenge) -> Bool {
        !challenge.isTodayCompleted && challenge.currentDay <= 100
    }
}

#Preview {
    let store = ChallengeStore.shared
    let appState = AppState()
    appState.currentTab = .progress

    let sampleChallenge1 = Challenge(
        title: "Daily Meditation",
        accentColor: "#4A90E2",
        startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
        completedDaysSet: Set(1...15)
    )
    let sampleChallenge2 = Challenge(
        title: "Morning Exercise",
        accentColor: "#50C878",
        startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
        completedDaysSet: Set([1, 2, 3, 5])
    )
    store.challenges = [sampleChallenge1, sampleChallenge2]

    return MainTabView()
        .environmentObject(store)
        .environmentObject(appState)
}

#Preview("Empty State") {
    let store = ChallengeStore.shared
    let appState = AppState()
    appState.currentTab = .progress
    store.challenges = []

    return MainTabView()
        .environmentObject(store)
        .environmentObject(appState)
}
