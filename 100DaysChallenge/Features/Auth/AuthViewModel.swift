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
    @Published var isPasswordVisible = false
    @Published private(set) var user: FirebaseAuth.User?

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let authHandle { Auth.auth().removeStateDidChangeListener(authHandle) }
    }

    var isAuthenticated: Bool { user != nil }
    
    // Validation for login form
    var isValidForLogin: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }
    
    // Validation for sign up form
    var isValidForSignUp: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    func signIn(completion: @escaping () -> Void) {
        guard isValidEmail(email) else { errorMessage = "Please enter a valid email"; return }
        guard isValidPassword(password) else { errorMessage = "Password must be at least 6 characters"; return }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.errorMessage = "Invalid email or password"
                } else {
                    self?.errorMessage = nil
                    completion()
                }
            }
        }
    }

    func signUp(completion: @escaping () -> Void) {
        guard isValidEmail(email) else { errorMessage = "Please enter a valid email"; return }
        guard isValidPassword(password) else { errorMessage = "Password must be at least 6 characters"; return }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        self?.errorMessage = "This email is already registered"
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                    return
                }

                result?.user.sendEmailVerification(completion: nil)
                self?.errorMessage = nil
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
            if let error = error {
                if (error as NSError).code != GIDSignInError.canceled.rawValue {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                self?.errorMessage = "Failed to get Google token"
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else {
                        self?.errorMessage = nil
                        completion()
                    }
                }
            }
        }
    }

    func resetPassword() {
        guard isValidEmail(email) else { errorMessage = "Invalid email format"; return }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = (error == nil)
                    ? "Password reset link has been sent to your email"
                    : error?.localizedDescription
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
}


