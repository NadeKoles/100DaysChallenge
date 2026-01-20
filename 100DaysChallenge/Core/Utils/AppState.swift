//
//  AppState.swift
//  100DaysChallenge
//
//  Global app state management
//

import Foundation
import SwiftUI

enum AppScreen {
    case splash
    case onboarding
    case signUp
    case login
    case main
}

enum MainTab {
    case progress
    case newChallenge
    case settings
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .splash
    @Published var currentTab: MainTab = .progress
    @Published var selectedChallengeId: String? = nil
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
    }
    
    func handleSplashComplete() {
        if hasCompletedOnboarding {
            if isAuthenticated {
                currentScreen = .main
            } else {
                currentScreen = .login
            }
        } else {
            currentScreen = .onboarding
        }
    }
    
    func handleOnboardingComplete() {
        hasCompletedOnboarding = true
        currentScreen = .signUp
    }
    
    func handleSignUpComplete() {
        isAuthenticated = true
        currentScreen = .main
    }
    
    func handleLoginComplete() {
        isAuthenticated = true
        currentScreen = .main
    }
    
    func handleLogout() {
        isAuthenticated = false
        currentScreen = .login
    }
}

