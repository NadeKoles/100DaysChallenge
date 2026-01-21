//
//  AppState.swift
//  100DaysChallenge
//
//  Global app state management
//

import Foundation
import SwiftUI

enum MainTab {
    case progress
    case newChallenge
    case settings
}

@MainActor
class AppState: ObservableObject {
    @Published var currentTab: MainTab = .progress
    @Published var selectedChallengeId: String? = nil
    @Published var didFinishLaunchSplash: Bool = false
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func handleSplashComplete() {
        didFinishLaunchSplash = true
    }
    
    func handleOnboardingComplete() {
        hasCompletedOnboarding = true
    }
}

