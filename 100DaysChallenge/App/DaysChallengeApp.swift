//
//  DaysChallengeApp.swift
//  100DaysChallenge
//
//  App entry point
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct DaysChallengeApp: App {
    @StateObject private var authVM: AuthViewModel
    @StateObject private var appState: AppState

    init() {
        FirebaseApp.configure()
        let auth = AuthViewModel()
        _authVM = StateObject(wrappedValue: auth)
        _appState = StateObject(wrappedValue: AppState(authViewModel: auth))
    }

    var body: some Scene {
        WindowGroup {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-screenshotMode") {
                ScreenshotRootView()
            } else {
                mainRoot
            }
#else
            mainRoot
#endif
        }
    }

    private var mainRoot: some View {
        RootView()
            .environmentObject(appState)
            .environmentObject(ChallengeStore.shared)
            .environmentObject(authVM)
            .onAppear {
                ChallengeStore.shared.switchToUser(authVM.user?.uid)
            }
            .onChange(of: authVM.user) { _, user in
                ChallengeStore.shared.switchToUser(user?.uid)
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
    }
}

