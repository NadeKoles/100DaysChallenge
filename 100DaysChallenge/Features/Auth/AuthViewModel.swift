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

// MARK: - Verify Email Alert State
struct VerifyEmailAlertState: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryTitle: String
}

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Feature Flags
    // TODO: Enable Sign in with Apple after enrolling in Apple Developer Program
    // Set to true once Apple Developer Program membership is active and Sign in with Apple is configured
    static let isAppleSignInEnabled = false
    
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
    @Published var resendCooldownSeconds: Int = 0
    @Published var verifyEmailAlert: VerifyEmailAlertState?
    @Published var isRefreshing = false

    private var authHandle: AuthStateDidChangeListenerHandle?
    private var cooldownTask: Task<Void, Never>?
    private var verifyReloadTask: Task<Void, Never>?
    private var rateLimitBackoffCount: Int = 0

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
        cooldownTask?.cancel()
        verifyReloadTask?.cancel()
    }

    var formattedResendCooldown: String {
        let seconds = resendCooldownSeconds
        guard seconds > 0 else { return "" }
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return "\(seconds)s"
        }
    }

    var resendVerificationButtonTitle: String {
        resendCooldownSeconds > 0
            ? LocalizedStrings.Auth.resendVerificationEmailWithCooldown(formattedResendCooldown)
            : LocalizedStrings.Auth.resendVerificationEmail
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
                            // Don't call completion - user needs to verify email first
                        }
                    }
                }
            }
        }
    }

    func signInWithApple(completion: @escaping () -> Void) {
        // Show info message when Apple Sign In is not yet enabled
        guard Self.isAppleSignInEnabled else {
            infoMessage = LocalizedStrings.Auth.appleSignInComingSoon
            return
        }
        
        // TODO: Implement Apple Sign In after enrolling in Apple Developer Program
        // This will require:
        // 1. Enrolling in Apple Developer Program
        // 2. Configuring Sign in with Apple capability in Xcode
        // 3. Setting up Sign in with Apple in Firebase Console
        // 4. Implementing ASAuthorizationControllerDelegate and ASAuthorizationControllerPresentationContextProviding
        completion()
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
        catch {
            errorMessage = error.localizedDescription
            verifyEmailAlert = VerifyEmailAlertState(
                title: LocalizedStrings.Auth.errorTitle,
                message: error.localizedDescription,
                primaryTitle: LocalizedStrings.Auth.ok
            )
        }
    }

    func dismissVerifyEmailAlert() {
        verifyEmailAlert = nil
        errorMessage = nil
        infoMessage = nil
    }

    // MARK: - Email Verification

    func sendEmailVerification() {
        guard let user = user else {
            let msg = LocalizedStrings.Auth.genericError
            errorMessage = msg
            verifyEmailAlert = VerifyEmailAlertState(
                title: LocalizedStrings.Auth.errorTitle,
                message: msg,
                primaryTitle: LocalizedStrings.Auth.ok
            )
            return
        }

        guard resendCooldownSeconds == 0 else { return }
        
        isLoading = true
        user.sendEmailVerification { [weak self] error in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    let authError = error as NSError
                    let errorCode = AuthErrorCode(rawValue: authError.code)
                    
                    // Check for rate-limit errors
                    if errorCode == .tooManyRequests ||
                       authError.localizedDescription.contains("TOO_MANY_ATTEMPTS_TRY_LATER") ||
                       authError.localizedDescription.lowercased().contains("too many") {
                        self.rateLimitBackoffCount += 1
                        let cooldownSeconds = self.rateLimitBackoffCount >= 2 ? 900 : 300 // 15 minutes if consecutive, else 5 minutes
                        let msg = LocalizedStrings.Auth.rateLimitExceeded
                        self.errorMessage = msg
                        self.verifyEmailAlert = VerifyEmailAlertState(
                            title: LocalizedStrings.Auth.errorTitle,
                            message: msg,
                            primaryTitle: LocalizedStrings.Auth.ok
                        )
                        self.startCooldown(seconds: cooldownSeconds)
                    } else {
                        self.rateLimitBackoffCount = 0 // Reset on non-rate-limit error
                        let errorMsg = LocalizedStrings.Auth.verificationEmailFailed(error.localizedDescription)
                        self.errorMessage = errorMsg
                        self.verifyEmailAlert = VerifyEmailAlertState(
                            title: LocalizedStrings.Auth.errorTitle,
                            message: errorMsg,
                            primaryTitle: LocalizedStrings.Auth.ok
                        )
                        self.startCooldown(seconds: 60) // 60 seconds for normal errors
                    }
                } else {
                    self.rateLimitBackoffCount = 0 // Reset on success
                    let msg = LocalizedStrings.Auth.verificationEmailSent
                    self.infoMessage = msg
                    self.verifyEmailAlert = VerifyEmailAlertState(
                        title: LocalizedStrings.Auth.infoTitle,
                        message: msg,
                        primaryTitle: LocalizedStrings.Auth.ok
                    )
                    self.startCooldown(seconds: 60) // 60 seconds after successful send
                }
            }
        }
    }
    
    private func startCooldown(seconds: Int) {
        resendCooldownSeconds = seconds
        cooldownTask?.cancel()
        
        cooldownTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            for remaining in (0..<seconds).reversed() {
                guard !Task.isCancelled else { return }
                self.resendCooldownSeconds = remaining
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }
            
            guard !Task.isCancelled else { return }
            self.resendCooldownSeconds = 0
        }
    }
    
    func reloadUser() async {
        guard let user = user else {
            let msg = LocalizedStrings.Auth.genericError
            errorMessage = msg
            verifyEmailAlert = VerifyEmailAlertState(
                title: LocalizedStrings.Auth.errorTitle,
                message: msg,
                primaryTitle: LocalizedStrings.Auth.ok
            )
            return
        }

        do {
            try await user.reload()
            // Update the user property by re-fetching from Auth
            self.user = Auth.auth().currentUser
            if let updatedUser = self.user, updatedUser.isEmailVerified {
                let msg = LocalizedStrings.Auth.emailVerified
                infoMessage = msg
                verifyEmailAlert = VerifyEmailAlertState(
                    title: LocalizedStrings.Auth.infoTitle,
                    message: msg,
                    primaryTitle: LocalizedStrings.Auth.ok
                )
            }
        } catch {
            let msg = mapAuthError(error)
            errorMessage = msg
            verifyEmailAlert = VerifyEmailAlertState(
                title: LocalizedStrings.Auth.errorTitle,
                message: msg,
                primaryTitle: LocalizedStrings.Auth.ok
            )
        }
    }

    func checkVerification() async {
        isRefreshing = true
        await reloadUser()
        isRefreshing = false
    }

    func onVerifyEmailDisappear() {
        verifyReloadTask?.cancel()
        verifyReloadTask = nil
        isRefreshing = false
    }

    func onVerifyEmailSceneActive() {
        verifyReloadTask?.cancel()
        verifyReloadTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            await self?.checkVerification()
        }
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


