//
//  AuthViewModel.swift
//  100DaysChallenge
//
//  Created by Nadia on 14/01/2026.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""             
    @Published var errorMessage: String?
    @Published var formError: String?
    @Published var infoMessage: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var nameError: String?
    // TODO: Implement password visibility toggle in InputField (eye icon) and connect to this state.
    @Published var isPasswordVisible = false
    @Published var isLoading = false
    @Published private(set) var user: FirebaseAuth.User?

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                self.user = user
            }
        }
    }

    deinit {
        if let authHandle { Auth.auth().removeStateDidChangeListener(authHandle) }
    }

    var isAuthenticated: Bool { user != nil }

    func signIn(completion: @escaping () -> Void) {
        guard validateForm(.login) else { return }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    let friendlyMessage = self.mapAuthError(error)
                    self.errorMessage = friendlyMessage
                    self.formError = friendlyMessage
                } else {
                    self.errorMessage = nil
                    self.formError = nil
                    completion()
                }
            }
        }
    }

    func signUp(completion: @escaping () -> Void) {
        guard validateForm(.signUp) else { return }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let error = error {
                    self.isLoading = false
                    let friendlyMessage = self.mapAuthError(error)
                    self.errorMessage = friendlyMessage
                    self.formError = friendlyMessage
                    return
                }

                guard let user = result?.user else {
                    self.isLoading = false
                    let errorMsg = LocalizedStrings.Auth.failedToCreateAccount
                    self.errorMessage = errorMsg
                    self.formError = errorMsg
                    return
                }

                // Persist user name to Firebase Auth profile
                let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedName.isEmpty {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = trimmedName
                    changeRequest.commitChanges { error in
                        // Profile update is non-critical; proceed with email verification even if it fails
                    }
                }

                user.sendEmailVerification { error in
                    Task { @MainActor in
                        if let error = error {
                            let errorMsg = LocalizedStrings.Auth.verificationEmailFailed(error.localizedDescription)
                            self.errorMessage = errorMsg
                            self.formError = errorMsg
                            self.isLoading = false
                            return
                        } else {
                            self.errorMessage = nil
                            self.formError = nil
                            self.isLoading = false
                            completion()
                        }
                    }
                }
            }
        }
    }

    func signInWithGoogle(completion: @escaping () -> Void) {
        // Prevent multiple simultaneous sign-in attempts
        guard !isLoading else { return }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = LocalizedStrings.Auth.missingFirebaseClientID
            formError = LocalizedStrings.Auth.missingFirebaseClientID
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else {
            errorMessage = LocalizedStrings.Auth.unableToAccessRootVC
            formError = LocalizedStrings.Auth.unableToAccessRootVC
            return
        }

        isLoading = true
        errorMessage = nil
        formError = nil
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let error = error {
                    self.isLoading = false
                    if (error as NSError).code != GIDSignInError.canceled.rawValue {
                        let friendlyMessage = self.mapAuthError(error)
                        self.errorMessage = friendlyMessage
                        self.formError = friendlyMessage
                    }
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    self.isLoading = false
                    self.errorMessage = LocalizedStrings.Auth.failedToGetGoogleToken
                    self.formError = LocalizedStrings.Auth.failedToGetGoogleToken
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { [weak self] _, error in
                    Task { @MainActor in
                        guard let self = self else { return }
                        self.isLoading = false
                        if let error = error {
                            let friendlyMessage = self.mapAuthError(error)
                            self.errorMessage = friendlyMessage
                            self.formError = friendlyMessage
                        } else {
                            self.errorMessage = nil
                            self.formError = nil
                            completion()
                        }
                    }
                }
            }
        }
    }

    func resetPassword(email: String) {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard Self.isValidEmail(normalized) else {
            errorMessage = LocalizedStrings.Auth.invalidEmail
            return
        }

        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: normalized) { [weak self] error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = self.mapAuthError(error)
                } else {
                    self.infoMessage = LocalizedStrings.Auth.passwordResetSent
                }
            }
        }
    }

    func signOut() {
        isLoading = false
        do { try Auth.auth().signOut() }
        catch { errorMessage = error.localizedDescription }
    }
    
    func resetFormState() {
        email = ""
        password = ""
        name = ""
        emailError = nil
        passwordError = nil
        nameError = nil
        errorMessage = nil
        formError = nil
        infoMessage = nil
    }
    
    func clearFormError() {
        formError = nil
    }

    static func isValidEmail(_ email: String) -> Bool {
        let r = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", r).evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool { password.count >= 6 }
    
    // MARK: - Form Validation
    enum FormType {
        case login
        case signUp
    }
    
    func validateForm(_ type: FormType) -> Bool {
        emailError = nil
        passwordError = nil
        nameError = nil
        var isValid = true
        
        if type == .signUp {
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                nameError = LocalizedStrings.Auth.nameRequired
                isValid = false
            }
        }
        
        if !Self.isValidEmail(email) {
            emailError = LocalizedStrings.Auth.invalidEmail
            isValid = false
        }
        
        if password.count < 6 {
            passwordError = LocalizedStrings.Auth.passwordTooShort
            isValid = false
        }
        
        return isValid
    }
    
    func validateLoginForm() -> Bool {
        validateForm(.login)
    }
    
    func validateSignUpForm() -> Bool {
        validateForm(.signUp)
    }
    
    // MARK: - Error Mapping
    private func mapAuthError(_ error: Error) -> String {
        guard let authError = error as NSError? else {
            return LocalizedStrings.Auth.genericError
        }
        
        guard let errorCode = AuthErrorCode(rawValue: authError.code) else {
            return LocalizedStrings.Auth.genericError
        }
        
        switch errorCode {
        case .invalidEmail:
            return LocalizedStrings.Auth.invalidEmail
        case .wrongPassword:
            return LocalizedStrings.Auth.incorrectPassword
        case .userNotFound:
            return LocalizedStrings.Auth.userNotFound
        case .invalidCredential:
            return LocalizedStrings.Auth.incorrectEmailOrPassword
        case .emailAlreadyInUse:
            return LocalizedStrings.Auth.emailAlreadyInUse
        case .weakPassword:
            return LocalizedStrings.Auth.passwordTooShort
        case .networkError:
            return LocalizedStrings.Auth.networkError
        case .tooManyRequests:
            return LocalizedStrings.Auth.tooManyRequests
        default:
            return LocalizedStrings.Auth.genericError
        }
    }
}


