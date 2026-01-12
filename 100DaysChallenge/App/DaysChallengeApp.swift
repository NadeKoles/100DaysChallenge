//
//  DaysChallengeApp.swift
//  100DaysChallenge
//
//  App entry point
//

import SwiftUI

@main
struct DaysChallengeApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(ChallengeStore.shared)
        }
    }
}

