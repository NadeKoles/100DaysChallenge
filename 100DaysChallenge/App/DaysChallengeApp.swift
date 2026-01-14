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
    @StateObject private var appState = AppState()
    @StateObject private var authVM = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(ChallengeStore.shared)
                .environmentObject(authVM)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

