//
//  NewChallengeViewModel.swift
//  100DaysChallenge
//
//  ViewModel for new challenge screen. Owns form state, validation, submission, and alert state.
//

import SwiftUI

// MARK: - Alert State

enum NewChallengeAlertState: Identifiable {
    case maxChallengesReached
    var id: Self { self }
}

// MARK: - ViewModel

@MainActor
class NewChallengeViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var selectedColorIndex: Int = 0
    @Published var alert: NewChallengeAlertState?
    @Published var isLoading: Bool = false

    private var challengeStore: ChallengeStore?
    private var appState: AppState?

    var selectedColor: Color {
        ChallengeAccentColor.all[selectedColorIndex].color
    }

    var selectedColorHex: String {
        ChallengeAccentColor.all[selectedColorIndex].hex
    }

    /// Whether the form can be submitted (non-empty trimmed title within limit).
    var isSubmitEnabled: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= InputLimits.challengeTitle
    }

    var alertTitle: String {
        switch alert {
        case .maxChallengesReached:
            return LocalizedStrings.NewChallenge.maxChallengesReached
        case .none:
            return ""
        }
    }

    var alertMessage: String {
        switch alert {
        case .maxChallengesReached:
            return LocalizedStrings.NewChallenge.maxChallengesMessage
        case .none:
            return ""
        }
    }

    func onAppear(challengeStore: ChallengeStore, appState: AppState) {
        self.challengeStore = challengeStore
        self.appState = appState
    }

    func setTitle(_ string: String) {
        title = String(string.prefix(InputLimits.challengeTitle))
    }

    func selectColor(_ index: Int) {
        selectedColorIndex = index
    }

    func submit() {
        guard let store = challengeStore, let app = appState else {
            assertionFailure("NewChallengeViewModel.submit() called before onAppear; challengeStore or appState is nil")
            return
        }
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= InputLimits.challengeTitle else { return }

        isLoading = true

        let challenge = Challenge(
            title: trimmed,
            accentColor: selectedColorHex,
            startDate: Date()
        )
        if store.addChallenge(challenge) {
            reset()
            app.selectedChallengeId = challenge.id
            app.currentTab = .progress
        } else {
            alert = .maxChallengesReached
        }

        Task { @MainActor in
            self.isLoading = false
        }
    }

    func dismissAlert() {
        alert = nil
    }

    func reset() {
        title = ""
        selectedColorIndex = 0
    }
}
