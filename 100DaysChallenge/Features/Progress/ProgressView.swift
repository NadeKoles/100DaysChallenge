//
//  ProgressView.swift
//  100DaysChallenge
//
//  Progress view with 100-day grid and challenge navigation
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var challengeStore: ChallengeStore
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
            isUnmarking ? "Unmark Day \(selectedDay ?? 0)?" : "Complete Day \(selectedDay ?? 0)?",
            isPresented: $showingConfirmModal
        ) {
            Button("Cancel", role: .cancel) {
                selectedDay = nil
                isUnmarking = false
            }
            Button(isUnmarking ? "Unmark" : "Complete") {
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
                    ? "Remove this day from your completed list?"
                    : "Great work! Keep the streak going.")
            }
        }
        .onAppear {
            updateCurrentChallengeId()
        }
        .onChange(of: viewModel.currentIndex) { _ in
            updateCurrentChallengeId()
        }
        .onChange(of: challengeStore.challenges) { _ in
            updateCurrentChallengeId()
        }
    }
    
    private func updateCurrentChallengeId() {
        if viewModel.currentIndex < challengeStore.challenges.count {
            viewModel.currentChallengeId = challengeStore.challenges[viewModel.currentIndex].id
        }
    }
}

struct EmptyChallengesView: View {
    var body: some View {
        VStack(spacing: Spacing.xl) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.xxl)
                    .fill(Color.gray100)
                    .frame(width: 96, height: 96)
                
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.gray400)
            }
            
            VStack(spacing: Spacing.sm) {
                Text("No Challenges Yet")
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                
                Text("Start your first 100-day challenge to build a lasting habit")
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
    
    var currentChallenge: Challenge {
        challenges[currentIndex]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Challenge indicator dots 
                        HStack(spacing: Spacing.sm) {
                            ForEach(0..<challenges.count, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(index == currentIndex ? 
                                          Color(hex: currentChallenge.accentColor) : Color.gray200)
                                    .frame(width: index == currentIndex ? 24 : 6, height: 6)
                                    .animation(.easeInOut, value: currentIndex)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.xs)
                        
                        // Challenge stats
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                                Text("\(currentChallenge.completedDaysSet.count)")
                                    .font(.displayMedium)
                                    .foregroundColor(.textPrimary)
                                
                                Text("/ 100")
                                    .font(.heading3)
                                    .foregroundColor(.textTertiary)
                            }
                            
                            Text("days completed")
                                .font(.body)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.lg)
                        
                        // Progress bar
                        ProgressBarView(
                            progress: currentChallenge.progress,
                            accentColor: Color(hex: currentChallenge.accentColor)
                        )
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.lg)
                        
                        // 100-day grid
                        ChallengeGridView(
                            challenge: currentChallenge,
                            onToggleDay: { day in
                                onToggleDay(currentChallenge.id, day)
                            }
                        )
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, shouldShowButton ? 80 : Spacing.xl)
                    }
                }
                
                // Sticky button at bottom
                if shouldShowButton {
                    Button(action: {
                        onCompleteToday(currentChallenge.id, currentChallenge.currentDay)
                    }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text("Mark Day \(currentChallenge.currentDay) Complete")
                                .font(.label)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: currentChallenge.accentColor))
                        .cornerRadius(CornerRadius.xl)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.background)
                }
            }
            .navigationTitle(currentChallenge.title)
            .navigationBarTitleDisplayMode(.large)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold && currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                            }
                        } else if value.translation.width < -threshold && currentIndex < challenges.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                        }
                    }
            )
        }
    }
    
    private var shouldShowButton: Bool {
        !currentChallenge.isTodayCompleted && currentChallenge.currentDay <= 100
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
