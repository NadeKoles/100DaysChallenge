//
//  ProgressView.swift
//  100DaysChallenge
//
//  Progress view with 100-day grid and challenge navigation
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var challengeStore: ChallengeStore
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProgressViewModel()
    @State private var showingConfirmModal = false
    @State private var selectedDay: Int? = nil
    @State private var isUnmarking = false
    
    var body: some View {
        Group {
            if challengeStore.challenges.isEmpty {
                EmptyChallengesView()
            } else {
                ChallengeProgressView(
                    challenges: challengeStore.challenges,
                    currentIndex: $viewModel.currentIndex,
                    onToggleDay: { challengeId, day in
                        let challenge = challengeStore.challenges.first { $0.id == challengeId }
                        if let challenge = challenge {
                            selectedDay = day
                            isUnmarking = challenge.completedDaysSet.contains(day)
                            showingConfirmModal = true
                        }
                    },
                    onCompleteToday: { challengeId, day in
                        challengeStore.completeDay(challengeId: challengeId, day: day)
                    }
                )
            }
        }
        .alert(
            isUnmarking 
                ? LocalizedStrings.Progress.unmarkDayTitleFormatted(selectedDay ?? 0)
                : LocalizedStrings.Progress.completeDayTitleFormatted(selectedDay ?? 0),
            isPresented: $showingConfirmModal
        ) {
            Button(LocalizedStrings.Progress.cancel, role: .cancel) {
                selectedDay = nil
                isUnmarking = false
            }
            Button(isUnmarking ? LocalizedStrings.Progress.unmark : LocalizedStrings.Progress.complete) {
                if let day = selectedDay,
                   !viewModel.currentChallengeId.isEmpty,
                   let challenge = challengeStore.challenges.first(where: { $0.id == viewModel.currentChallengeId }) {
                    if isUnmarking {
                        challengeStore.toggleDay(challengeId: challenge.id, day: day)
                    } else {
                        challengeStore.completeDay(challengeId: challenge.id, day: day)
                    }
                    selectedDay = nil
                    isUnmarking = false
                }
            }
        } message: {
            if selectedDay != nil {
                Text(isUnmarking 
                    ? LocalizedStrings.Progress.unmarkDayMessage
                    : LocalizedStrings.Progress.completeDayMessage)
            }
        }
        .onAppear {
            updateCurrentChallengeId()
            navigateToSelectedChallenge()
        }
        .onChange(of: viewModel.currentIndex) {
            updateCurrentChallengeId()
        }
        .onChange(of: challengeStore.challenges) { oldValue, newValue in
            // Handle challenge deletion: adjust index if current challenge was deleted
            if newValue.isEmpty {
                viewModel.currentIndex = 0
            } else if viewModel.currentIndex >= newValue.count {
                // Current challenge was deleted, move to last available challenge
                viewModel.currentIndex = max(0, newValue.count - 1)
            }
            updateCurrentChallengeId()
            navigateToSelectedChallenge()
        }
        .onChange(of: appState.selectedChallengeId) {
            navigateToSelectedChallenge()
        }
    }
    
    private func updateCurrentChallengeId() {
        let safeIndex = max(0, min(viewModel.currentIndex, challengeStore.challenges.count - 1))
        if safeIndex >= 0 && safeIndex < challengeStore.challenges.count {
            viewModel.currentChallengeId = challengeStore.challenges[safeIndex].id
        } else {
            viewModel.currentChallengeId = ""
        }
    }
    
    private func navigateToSelectedChallenge() {
        guard let selectedId = appState.selectedChallengeId,
              let index = challengeStore.challenges.firstIndex(where: { $0.id == selectedId }) else {
            return
        }
        
        // Navigate to the selected challenge
        if index != viewModel.currentIndex {
            withAnimation {
                viewModel.currentIndex = index
            }
        }
        
        // Clear the selected challenge ID after navigating
        appState.selectedChallengeId = nil
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
    @Binding var currentIndex: Int
    let onToggleDay: (String, Int) -> Void
    let onCompleteToday: (String, Int) -> Void
    
    private var safeCurrentIndex: Int {
        guard !challenges.isEmpty else { return 0 }
        return max(0, min(currentIndex, challenges.count - 1))
    }
    
    var currentChallenge: Challenge? {
        guard safeCurrentIndex >= 0 && safeCurrentIndex < challenges.count else {
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
                                    onToggleDay: { day in
                                        onToggleDay(challenge.id, day)
                                    }
                                )
                                .padding(.horizontal, Spacing.xl)
                                .padding(.bottom, shouldShowButton(challenge) ? 80 : Spacing.xl)
                            }
                        }
                        
                        // Sticky button at bottom
                        if shouldShowButton(challenge) {
                            PrimaryButton(
                                title: LocalizedStrings.Progress.markDayCompleteFormatted(challenge.currentDay),
                                action: {
                                    onCompleteToday(challenge.id, challenge.currentDay)
                                },
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
                                let safeIndex = safeCurrentIndex
                                if value.translation.width > threshold && safeIndex > 0 {
                                    withAnimation {
                                        currentIndex = safeIndex - 1
                                    }
                                } else if value.translation.width < -threshold && safeIndex < challenges.count - 1 {
                                    withAnimation {
                                        currentIndex = safeIndex + 1
                                    }
                                }
                            }
                    )
                }
            } else {
                // Fallback empty state if no challenge available
                ContentUnavailableView {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.gray400)
                } description: {
                    Text("No challenge available")
                        .font(.heading2)
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .onChange(of: challenges.count) { _, newCount in
            // Ensure currentIndex is within bounds when challenges array changes
            if newCount > 0 {
                currentIndex = max(0, min(currentIndex, newCount - 1))
            } else {
                currentIndex = 0
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
