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
    @Published var isPasswordVisible = false
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
    
    // Validation for login form
    var isValidForLogin: Bool {
        isValidEmail(email) && password.count >= 6
    }
    
    // Validation for sign up form
    var isValidForSignUp: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(email) &&
        password.count >= 6
    }

    func signIn(completion: @escaping () -> Void) {
        guard isValidEmail(email) else { errorMessage = "Please enter a valid email"; return }
        guard isValidPassword(password) else { errorMessage = "Password must be at least 6 characters"; return }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            Task { @MainActor in
                guard let self = self else { return }
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
        guard isValidEmail(email) else { errorMessage = "Please enter a valid email"; return }
        guard isValidPassword(password) else { errorMessage = "Password must be at least 6 characters"; return }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = self.mapAuthError(error)
                    return
                }

                result?.user.sendEmailVerification(completion: nil)
                self.errorMessage = nil
                completion()
            }
        }
    }

    func signInWithGoogle(completion: @escaping () -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Firebase clientID"
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController
        else {
            errorMessage = "Unable to access root view controller"
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let error = error {
                    if (error as NSError).code != GIDSignInError.canceled.rawValue {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
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
        guard isValidEmail(email) else { errorMessage = "Please enter a valid email"; return }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            Task { @MainActor in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = self.mapAuthError(error)
                } else {
                    self.infoMessage = "Password reset link has been sent"
                }
            }
        }
    }

    func signOut() {
        do { try Auth.auth().signOut() }
        catch { errorMessage = error.localizedDescription }
    }

    func isValidEmail(_ email: String) -> Bool {
        let r = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", r).evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool { password.count >= 6 }
    
    // MARK: - Form Validation
    func validateSignUpForm() -> Bool {
        emailError = nil
        passwordError = nil
        var ok = true
        
        if !isValidEmail(email) {
            emailError = "Please enter a valid email"
            ok = false
        }
        
        if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
            ok = false
        }
        
        return ok
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


