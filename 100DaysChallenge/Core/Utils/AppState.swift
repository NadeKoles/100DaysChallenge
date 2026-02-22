//
//  AppState.swift
//  100DaysChallenge
//
//  Global app state management and single source of truth for root routing.
//

import Combine
import Foundation
import SwiftUI

enum MainTab {
    case progress
    case newChallenge
    case settings
}

enum AuthRoute: CustomStringConvertible {
    case login
    case signUp

    var description: String {
        switch self {
        case .login: return "login"
        case .signUp: return "signUp"
        }
    }
}

enum RootRoute: CustomStringConvertible {
    case splash
    case onboarding
    case auth(AuthRoute)
    case verifyEmail
    case main

    var description: String {
        switch self {
        case .splash: return "splash"
        case .onboarding: return "onboarding"
        case .auth(let r): return "auth(\(r))"
        case .verifyEmail: return "verifyEmail"
        case .main: return "main"
        }
    }
}

private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

@MainActor
class AppState: ObservableObject {
    @Published var currentTab: MainTab = .progress
    @Published var selectedChallengeId: String? = nil
    @Published var didFinishLaunchSplash: Bool = false
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)
        }
    }
    @Published var authRoute: AuthRoute = .login
    @Published private(set) var rootRoute: RootRoute = .splash

    private let authViewModel: AuthViewModel
    private let hadCompletedOnboardingAtLaunch: Bool
    private var cancellables = Set<AnyCancellable>()

    init(authViewModel: AuthViewModel) {
        let stored = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        self.hasCompletedOnboarding = stored
        self.hadCompletedOnboardingAtLaunch = stored
        self.authViewModel = authViewModel
        if !stored {
            authViewModel.clearPersistedSession()
        }
        setUpRootRouteDerivation()
    }

    /// For SwiftUI previews only; production wiring uses init(authViewModel:).
    convenience init() {
        self.init(authViewModel: AuthViewModel())
    }

    private func setUpRootRouteDerivation() {
        Publishers.CombineLatest2(
            Publishers.CombineLatest4($didFinishLaunchSplash, $hasCompletedOnboarding, authViewModel.$user, $authRoute),
            authViewModel.$hasAuthenticatedThisSession
        )
        .map { [weak self] arg, hasAuthenticated in
            let (splashDone, onboardingDone, user, authRoute) = arg
            guard let self = self else { return RootRoute.splash }
            if !splashDone { return .splash }
            if !onboardingDone { return .onboarding }
            if onboardingDone && !self.hadCompletedOnboardingAtLaunch && !hasAuthenticated {
                return .auth(authRoute)
            }
            guard let user else { return .auth(authRoute) }
            if !user.isEmailVerified { return .verifyEmail }
            return .main
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] route in
            guard let self else { return }
            let previous = self.rootRoute
            self.rootRoute = route
            #if DEBUG
            if previous != route {
                debugPrint("[AppState] rootRoute: \(previous.description) → \(route.description)")
            }
            #endif
        }
        .store(in: &cancellables)
    }

    func handleSplashComplete() {
        didFinishLaunchSplash = true
    }

    func handleOnboardingComplete() {
        hasCompletedOnboarding = true
        authViewModel.resetFormState()
    }

    func showLogin() {
        authRoute = .login
        authViewModel.resetFormState()
    }

    func showSignUp() {
        authRoute = .signUp
        authViewModel.resetFormState()
    }

    func signOut() {
        authViewModel.signOut()
    }
}
