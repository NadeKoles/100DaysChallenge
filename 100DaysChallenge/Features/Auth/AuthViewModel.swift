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
    @Published var infoMessage: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var nameError: String?
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
                    self.errorMessage = self.mapAuthError(error)
                } else {
                    self.errorMessage = nil
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
                    self.errorMessage = self.mapAuthError(error)
                    return
                }

                guard let user = result?.user else {
                    self.isLoading = false
                    self.errorMessage = "Failed to create user account"
                    return
                }

                user.sendEmailVerification { error in
                    Task { @MainActor in
                        self.isLoading = false
                        if let error = error {
                            self.errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                        }
                        self.errorMessage = nil
                        completion()
                    }
                }
            }
        }
    }

    func signInWithGoogle(completion: @escaping () -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Firebase clientID"
            isLoading = false
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else {
            errorMessage = "Unable to access root view controller"
            isLoading = false
            return
        }

        isLoading = true
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let error = error {
                    self.isLoading = false
                    if (error as NSError).code != GIDSignInError.canceled.rawValue {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    self.isLoading = false
                    self.errorMessage = "Failed to get Google token"
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
                            self.errorMessage = self.mapAuthError(error)
                        } else {
                            self.errorMessage = nil
                            completion()
                        }
                    }
                }
            }
        }
    }

    func resetPassword() {
        emailError = nil
        guard isValidEmail(email) else {
            emailError = "Please enter a valid email"
            return
        }

        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = self.mapAuthError(error)
                } else {
                    self.infoMessage = "Password reset link has been sent"
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
        infoMessage = nil
    }

    func isValidEmail(_ email: String) -> Bool {
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
                nameError = "Please enter your name"
                isValid = false
            }
        }
        
        if !isValidEmail(email) {
            emailError = "Please enter a valid email"
            isValid = false
        }
        
        if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
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
            return error.localizedDescription
        }
        
        guard let errorCode = AuthErrorCode(rawValue: authError.code) else {
            return error.localizedDescription
        }
        
        switch errorCode {
        case .invalidEmail:
            return "Please enter a valid email"
        case .wrongPassword:
            return "Incorrect password"
        case .userNotFound:
            return "No account found with this email"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .networkError:
            return "Network error. Please try again."
        case .tooManyRequests:
            return "Too many attempts. Try again later."
        default:
            return error.localizedDescription
        }
    }
}


