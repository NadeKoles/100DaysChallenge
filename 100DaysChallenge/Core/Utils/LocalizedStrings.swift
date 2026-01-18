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
        static let emailPlaceholder = NSLocalizedString("auth.emailPlaceholder", value: "name@example.com", comment: "Email field placeholder")
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
        static let or = NSLocalizedString("auth.or", value: "or", comment: "Divider text between login methods")
        static let continueWithGoogle = NSLocalizedString("auth.continueWithGoogle", value: "Continue with Google", comment: "Google sign-in button")
        static let dontHaveAccount = NSLocalizedString("auth.dontHaveAccount", value: "Don't have an account?", comment: "Sign up link text")
        static let signUp = NSLocalizedString("auth.signUp", value: "Sign up", comment: "Sign up link button")
        
        // Validation messages
        static let invalidEmail = NSLocalizedString("auth.invalidEmail", value: "Please enter a valid email", comment: "Email validation error")
        static let passwordTooShort = NSLocalizedString("auth.passwordTooShort", value: "Password must be at least 6 characters", comment: "Password validation error")
        static let nameRequired = NSLocalizedString("auth.nameRequired", value: "Please enter your name", comment: "Name validation error")
        
        // Info messages
        static let passwordResetSent = NSLocalizedString("auth.passwordResetSent", value: "Password reset link has been sent", comment: "Password reset success message")
        
        // Reset password prompt
        static let resetPasswordTitle = NSLocalizedString("auth.resetPasswordTitle", value: "Reset Password", comment: "Reset password alert title")
        static let resetPasswordMessage = NSLocalizedString("auth.resetPasswordMessage", value: "Enter your email and we'll send you a reset link.", comment: "Reset password alert message")
        static let cancel = NSLocalizedString("auth.cancel", value: "Cancel", comment: "Cancel button")
        static let send = NSLocalizedString("auth.send", value: "Send", comment: "Send button")
        
        // Error messages
        static let missingFirebaseClientID = NSLocalizedString("auth.missingFirebaseClientID", value: "Something went wrong. Please try again.", comment: "Firebase configuration error")
        static let unableToAccessRootVC = NSLocalizedString("auth.unableToAccessRootVC", value: "Unable to continue. Please try again.", comment: "UI access error")
        static let failedToCreateAccount = NSLocalizedString("auth.failedToCreateAccount", value: "Failed to create user account", comment: "Account creation error")
        static let failedToGetGoogleToken = NSLocalizedString("auth.failedToGetGoogleToken", value: "Failed to get Google token", comment: "Google sign-in error")
        
        // Dynamic error messages
        static func verificationEmailFailed(_ details: String) -> String {
            let format = NSLocalizedString("auth.verificationEmailFailed", value: "Failed to send verification email: %@", comment: "Email verification error with details")
            return String(format: format, details)
        }
        
        // Auth error mappings
        static let incorrectPassword = NSLocalizedString("auth.incorrectPassword", value: "Incorrect password", comment: "Wrong password error")
        static let incorrectEmailOrPassword = NSLocalizedString("auth.incorrectEmailOrPassword", value: "Incorrect email or password", comment: "Invalid credentials error")
        static let userNotFound = NSLocalizedString("auth.userNotFound", value: "No account found with this email", comment: "User not found error")
        static let emailAlreadyInUse = NSLocalizedString("auth.emailAlreadyInUse", value: "This email is already registered", comment: "Email already registered error")
        static let networkError = NSLocalizedString("auth.networkError", value: "Network error. Please try again.", comment: "Network error message")
        static let tooManyRequests = NSLocalizedString("auth.tooManyRequests", value: "Too many attempts. Try again later.", comment: "Too many requests error")
        static let genericError = NSLocalizedString("auth.genericError", value: "Something went wrong. Please try again.", comment: "Generic error message")
        
        // Alert titles
        static let errorTitle = NSLocalizedString("auth.errorTitle", value: "Error", comment: "Error alert title")
        static let infoTitle = NSLocalizedString("auth.infoTitle", value: "Info", comment: "Info alert title")
    }
}
