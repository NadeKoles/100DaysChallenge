//
//  ProgressViewModel.swift
//  100DaysChallenge
//
//  ViewModel for Progress: selected challenge, day toggles, alert state, and navigation.
//

import Foundation
import SwiftUI

/// Alert content for the day complete/unmark confirmation.
struct ProgressAlertState {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let day: Int
    let isUnmarking: Bool
}

@MainActor
class ProgressViewModel: ObservableObject {
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var currentChallengeId: String = ""
    @Published private(set) var alert: ProgressAlertState?

    private weak var challengeStore: ChallengeStore?
    private weak var appState: AppState?

    // MARK: - Configuration

    func onAppear(challengeStore: ChallengeStore, appState: AppState) {
        self.challengeStore = challengeStore
        self.appState = appState
        syncCurrentChallengeId()
        navigateToSelectedChallengeIfNeeded()
    }

    // MARK: - Intents

    func selectChallenge(_ id: String) {
        guard let store = challengeStore,
              let index = store.challenges.firstIndex(where: { $0.id == id }) else {
            return
        }
        if index != currentIndex {
            withAnimation {
                currentIndex = index
            }
        }
        syncCurrentChallengeId()
    }

    func didTapDay(_ day: Int) {
        guard let store = challengeStore else { return }
        let challenge = store.challenges.first { $0.id == currentChallengeId }
        guard let challenge = challenge else { return }

        let isUnmarking = challenge.completedDaysSet.contains(day)
        alert = ProgressAlertState(
            title: isUnmarking
                ? LocalizedStrings.Progress.unmarkDayTitleFormatted(day)
                : LocalizedStrings.Progress.completeDayTitleFormatted(day),
            message: isUnmarking
                ? LocalizedStrings.Progress.unmarkDayMessage
                : LocalizedStrings.Progress.completeDayMessage,
            primaryButtonTitle: isUnmarking ? LocalizedStrings.Progress.unmark : LocalizedStrings.Progress.complete,
            day: day,
            isUnmarking: isUnmarking
        )
    }

    func confirmToggleDay() {
        guard let a = alert, let store = challengeStore, !currentChallengeId.isEmpty else {
            alert = nil
            return
        }
        if a.isUnmarking {
            store.toggleDay(challengeId: currentChallengeId, day: a.day)
        } else {
            store.completeDay(challengeId: currentChallengeId, day: a.day)
        }
        alert = nil
    }

    func cancelToggleDay() {
        alert = nil
    }

    func markDayComplete(day: Int) {
        guard !currentChallengeId.isEmpty else { return }
        challengeStore?.completeDay(challengeId: currentChallengeId, day: day)
    }

    func previousChallenge() {
        guard let store = challengeStore, !store.challenges.isEmpty else { return }
        let safe = max(0, min(currentIndex, store.challenges.count - 1))
        if safe > 0 {
            withAnimation {
                currentIndex = safe - 1
            }
            syncCurrentChallengeId()
        }
    }

    func nextChallenge() {
        guard let store = challengeStore, !store.challenges.isEmpty else { return }
        let safe = max(0, min(currentIndex, store.challenges.count - 1))
        if safe < store.challenges.count - 1 {
            withAnimation {
                currentIndex = safe + 1
            }
            syncCurrentChallengeId()
        }
    }

    func handleChallengesUpdated(count: Int) {
        if count == 0 {
            currentIndex = 0
            currentChallengeId = ""
        } else if currentIndex >= count {
            currentIndex = max(0, count - 1)
            syncCurrentChallengeId()
        } else {
            syncCurrentChallengeId()
        }
    }

    func handleCurrentIndexChanged() {
        syncCurrentChallengeId()
    }

    func navigateToSelectedChallengeIfNeeded() {
        guard let app = appState, let selectedId = app.selectedChallengeId,
              let store = challengeStore,
              let index = store.challenges.firstIndex(where: { $0.id == selectedId }) else {
            return
        }
        if index != currentIndex {
            withAnimation {
                currentIndex = index
            }
        }
        syncCurrentChallengeId()
        appState?.selectedChallengeId = nil
    }

    // MARK: - Computed (for View binding)

    var progressFraction: Double {
        guard let store = challengeStore,
              let challenge = store.challenges.first(where: { $0.id == currentChallengeId }) else {
            return 0
        }
        return challenge.progress
    }

    // MARK: - Private

    private func syncCurrentChallengeId() {
        guard let store = challengeStore else {
            currentChallengeId = ""
            return
        }
        let count = store.challenges.count
        if count == 0 {
            currentChallengeId = ""
            return
        }
        let safe = max(0, min(currentIndex, count - 1))
        currentChallengeId = store.challenges[safe].id
    }
}
