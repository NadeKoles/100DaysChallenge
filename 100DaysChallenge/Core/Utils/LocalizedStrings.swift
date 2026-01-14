//
//  LocalizedStrings.swift
//  100DaysChallenge
//
//  Localization helper for string management
//

import Foundation

enum LocalizedStrings {
    // MARK: - Auth
    enum Auth {
        static let createAccount = NSLocalizedString("auth.createAccount", value: "Create Account", comment: "Sign up screen title")
        static let startJourney = NSLocalizedString("auth.startJourney", value: "Start your journey to building lasting habits", comment: "Sign up screen subtitle")
        static let name = NSLocalizedString("auth.name", value: "Name", comment: "Name field label")
        static let namePlaceholder = NSLocalizedString("auth.namePlaceholder", value: "Your name", comment: "Name field placeholder")
        static let email = NSLocalizedString("auth.email", value: "Email", comment: "Email field label")
        static let emailPlaceholder = NSLocalizedString("auth.emailPlaceholder", value: "your@email.com", comment: "Email field placeholder")
        static let password = NSLocalizedString("auth.password", value: "Password", comment: "Password field label")
        static let passwordPlaceholder = NSLocalizedString("auth.passwordPlaceholder", value: "Create a password", comment: "Password field placeholder")
        static let createAccountButton = NSLocalizedString("auth.createAccountButton", value: "Create Account", comment: "Sign up button")
        static let alreadyHaveAccount = NSLocalizedString("auth.alreadyHaveAccount", value: "Already have an account?", comment: "Login link text")
        static let logIn = NSLocalizedString("auth.logIn", value: "Log in", comment: "Login link button")
        
        // Login screen
        static let welcomeBack = NSLocalizedString("auth.welcomeBack", value: "Welcome Back", comment: "Login screen title")
        static let continueJourney = NSLocalizedString("auth.continueJourney", value: "Continue your journey", comment: "Login screen subtitle")
        static let passwordPlaceholderLogin = NSLocalizedString("auth.passwordPlaceholderLogin", value: "Your password", comment: "Password field placeholder for login")
        static let forgotPassword = NSLocalizedString("auth.forgotPassword", value: "Forgot password?", comment: "Forgot password link")
        static let logInButton = NSLocalizedString("auth.logInButton", value: "Log In", comment: "Login button")
        static let dontHaveAccount = NSLocalizedString("auth.dontHaveAccount", value: "Don't have an account?", comment: "Sign up link text")
        static let signUp = NSLocalizedString("auth.signUp", value: "Sign up", comment: "Sign up link button")
    }
}
