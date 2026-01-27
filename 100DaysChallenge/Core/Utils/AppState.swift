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

enum AuthRoute {
    case login
    case signUp
}

enum RootRoute {
    case splash
    case onboarding
    case auth(AuthRoute)
    case verifyEmail
    case main
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
    @Published var authRoute: AuthRoute = .login
    @Published private(set) var rootRoute: RootRoute = .splash

    private let authViewModel: AuthViewModel
    private var cancellables = Set<AnyCancellable>()

    init(authViewModel: AuthViewModel) {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.authViewModel = authViewModel
        setUpRootRouteDerivation()
    }

    /// For SwiftUI previews only; production wiring uses init(authViewModel:).
    convenience init() {
        self.init(authViewModel: AuthViewModel())
    }

    private func setUpRootRouteDerivation() {
        Publishers.CombineLatest4($didFinishLaunchSplash, $hasCompletedOnboarding, authViewModel.$user, $authRoute)
            .map { [weak self] splashDone, onboardingDone, user, authRoute in
                guard self != nil else { return RootRoute.splash }
                if !splashDone { return .splash }
                if !onboardingDone { return .onboarding }
                guard let user else { return .auth(authRoute) }
                if !user.isEmailVerified { return .verifyEmail }
                return .main
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.rootRoute = route
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
