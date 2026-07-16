//
//  ProgressScreenshotPreview.swift
//  100DaysChallenge
//
//  DEBUG-only fixture for producing the README progress screenshot: mock
//  "Meditation" challenge with days marked to match the reference shot.
//  Tap the affirmation card to cycle candidate lines and pick the best one.
//

#if DEBUG
import SwiftUI

private struct StubAffirmationClient: HTTPClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let json = "{\"affirmation\":\"\(await AffirmationViewModel.previewAffirmations[0])\"}"
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (Data(json.utf8), response)
    }
}

private struct ScreenshotHarness: View {
    @StateObject private var affirmationViewModel = AffirmationViewModel(
        service: AffirmationService(client: StubAffirmationClient()),
        defaults: UserDefaults(suiteName: "screenshot.preview")!
    )

    private let challenges: [Challenge] = [
        Challenge(
            title: "Meditation",
            accentColor: "#6BCF94",
            startDate: Calendar.current.date(byAdding: .day, value: -24, to: Date()) ?? Date(),
            completedDaysSet: [1, 2, 3, 4, 5, 6, 8, 9, 10, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
        ),
        Challenge(title: "Reading", accentColor: "#5C9FFF"),
        Challenge(title: "Running", accentColor: "#F56B6B")
    ]

    var body: some View {
        ChallengeProgressView(
            challenges: challenges,
            currentIndex: 0,
            affirmationViewModel: affirmationViewModel,
            onSwipePrevious: {},
            onSwipeNext: {},
            onToggleDay: { _ in },
            onCompleteToday: { _ in }
        )
    }
}

#Preview("Screenshot — Progress") {
    ScreenshotHarness()
}

// Full-app screenshot root: launch with `-screenshotMode` to boot straight into
// the mock Meditation challenge (real tab bar + status bar), skipping auth.
struct ScreenshotRootView: View {
    @StateObject private var store: ChallengeStore
    @StateObject private var appState: AppState
    @StateObject private var authViewModel: AuthViewModel

    init() {
        let auth = AuthViewModel()
        let state = AppState(authViewModel: auth)
        state.currentTab = .progress
        _authViewModel = StateObject(wrappedValue: auth)
        _appState = StateObject(wrappedValue: state)
        _store = StateObject(wrappedValue: ChallengeStore.previewScreenshot())
    }

    var body: some View {
        MainTabView()
            .environmentObject(store)
            .environmentObject(appState)
            .environmentObject(authViewModel)
    }
}
#endif
