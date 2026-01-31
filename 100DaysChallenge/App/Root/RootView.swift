//
//  RootView.swift
//  100DaysChallenge
//
//  Declarative root: renders the screen for the current appState.rootRoute only.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.rootRoute {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .auth(.login):
                LoginView(showSignUp: authSignUpBinding)
            case .auth(.signUp):
                SignUpView(showSignUp: authSignUpBinding)
            case .verifyEmail:
                VerifyEmailView()
            case .main:
                MainTabView()
            }
        }
    }

    private var authSignUpBinding: Binding<Bool> {
        Binding(
            get: { appState.authRoute == .signUp },
            set: { if $0 { appState.showSignUp() } else { appState.showLogin() } }
        )
    }
}
