//
//  RootView.swift
//  100DaysChallenge
//
//  Root view that handles navigation between screens
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false
    
    var body: some View {
        Group {
            if !appState.didFinishLaunchSplash {
                SplashView()
            }
            else if !appState.hasCompletedOnboarding {
                OnboardingView()
            }
            else if authViewModel.user == nil {
                if showSignUp {
                    SignUpView(showSignUp: $showSignUp)
                } else {
                    LoginView(showSignUp: $showSignUp)
                }
            }
            else {
                MainTabView()
            }
        }
    }
}

