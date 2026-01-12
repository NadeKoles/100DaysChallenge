//
//  RootView.swift
//  100DaysChallenge
//
//  Root view that handles navigation between screens
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            switch appState.currentScreen {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .signUp:
                SignUpView()
            case .login:
                LoginView()
            case .main:
                MainTabView()
            }
        }
    }
}

