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
        static let continueWithApple = NSLocalizedString("auth.continueWithApple", value: "Continue with Apple", comment: "Apple sign-in button")
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
        static let appleSignInComingSoon = NSLocalizedString("auth.appleSignInComingSoon", value: "Sign in with Apple will be available soon.", comment: "Apple sign-in coming soon message")
        
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
        static let rateLimitExceeded = NSLocalizedString("auth.rateLimitExceeded", value: "Too many requests. Please wait a few minutes before trying again.", comment: "Rate limit exceeded error")
        static let genericError = NSLocalizedString("auth.genericError", value: "Something went wrong. Please try again.", comment: "Generic error message")
        
        // Alert titles
        static let errorTitle = NSLocalizedString("auth.errorTitle", value: "Error", comment: "Error alert title")
        static let infoTitle = NSLocalizedString("auth.infoTitle", value: "Info", comment: "Info alert title")
        static let ok = NSLocalizedString("auth.ok", value: "OK", comment: "Alert primary button")
        
        // Email verification
        static let verifyEmailTitle = NSLocalizedString("auth.verifyEmailTitle", value: "Verify Your Email", comment: "Email verification screen title")
        static let verifyEmailMessage = NSLocalizedString("auth.verifyEmailMessage", value: "We've sent a verification email to your inbox. Please check your email (including Spam folder) and click the verification link to continue.", comment: "Email verification screen message")
        static let resendVerificationEmail = NSLocalizedString("auth.resendVerificationEmail", value: "Resend Email", comment: "Resend verification email button")
        static func resendVerificationEmailWithCooldown(_ formattedTime: String) -> String {
            let format = NSLocalizedString("auth.resendVerificationEmailWithCooldown", value: "Resend Email (%@)", comment: "Resend verification email button with cooldown")
            return String(format: format, formattedTime)
        }
        static let iVerifiedRefresh = NSLocalizedString("auth.iVerifiedRefresh", value: "I Verified, Refresh", comment: "Refresh after verification button")
        static let logOut = NSLocalizedString("auth.logOut", value: "Log Out", comment: "Log out button")
        static let verificationEmailSent = NSLocalizedString("auth.verificationEmailSent", value: "Verification email sent", comment: "Verification email sent success message")
        static let emailVerified = NSLocalizedString("auth.emailVerified", value: "Email verified successfully", comment: "Email verified success message")
    }
    
    // MARK: - Splash
    enum Splash {
        static let title = NSLocalizedString("splash.title", value: "100 Days", comment: "Splash screen title")
        static let subtitle = NSLocalizedString("splash.subtitle", value: "Build lasting habits", comment: "Splash screen subtitle")
    }
    
    // MARK: - Tabs
    enum Tabs {
        static let progress = NSLocalizedString("tabs.progress", value: "Progress", comment: "Tab bar label")
        static let newChallenge = NSLocalizedString("tabs.newChallenge", value: "New", comment: "Tab bar label")
    }
    
    // MARK: - Progress
    enum Progress {
        static let noChallengesYet = NSLocalizedString("progress.noChallengesYet", value: "No Challenges Yet", comment: "Empty state title")
        static let noChallengeAvailable = NSLocalizedString("progress.noChallengeAvailable", value: "No challenge available", comment: "Content unavailable when no challenge selected")
        static let gridTitle = NSLocalizedString("progress.gridTitle", value: "100 DAYS GRID", comment: "100-day grid section header")
        static let noChallengesDescription = NSLocalizedString("progress.noChallengesDescription", value: "Start your first 100-days challenge to build a lasting habit", comment: "Empty state description")
        static let daysCompleted = NSLocalizedString("progress.daysCompleted", value: "days completed", comment: "Days completed label")
        static let markDayComplete = NSLocalizedString("progress.markDayComplete", value: "Mark Day %d Complete", comment: "Mark day complete button")
        static let completeDayTitle = NSLocalizedString("progress.completeDayTitle", value: "Complete Day %d?", comment: "Complete day alert title")
        static let unmarkDayTitle = NSLocalizedString("progress.unmarkDayTitle", value: "Unmark Day %d?", comment: "Unmark day alert title")
        static let completeDayMessage = NSLocalizedString("progress.completeDayMessage", value: "Great work! Keep the streak going.", comment: "Complete day alert message")
        static let unmarkDayMessage = NSLocalizedString("progress.unmarkDayMessage", value: "Remove this day from your completed list?", comment: "Unmark day alert message")
        static let complete = NSLocalizedString("progress.complete", value: "Complete", comment: "Complete button")
        static let unmark = NSLocalizedString("progress.unmark", value: "Unmark", comment: "Unmark button")
        static let cancel = NSLocalizedString("progress.cancel", value: "Cancel", comment: "Cancel button")
        
        static func markDayCompleteFormatted(_ day: Int) -> String {
            String(format: markDayComplete, day)
        }
        
        static func completeDayTitleFormatted(_ day: Int) -> String {
            String(format: completeDayTitle, day)
        }
        
        static func unmarkDayTitleFormatted(_ day: Int) -> String {
            String(format: unmarkDayTitle, day)
        }
    }
    
    // MARK: - New Challenge
    enum NewChallenge {
        static let title = NSLocalizedString("newChallenge.title", value: "New Challenge", comment: "New challenge screen title")
        static let whatDoYouWantToAchieve = NSLocalizedString("newChallenge.whatDoYouWantToAchieve", value: "What do you want to achieve?", comment: "Title input label")
        static let placeholder = NSLocalizedString("newChallenge.placeholder", value: "Enter a habit to practice every day", comment: "Title input placeholder")
        static let quickIdeas = NSLocalizedString("newChallenge.quickIdeas", value: "Quick ideas", comment: "Quick ideas section title")
        static let pickAColor = NSLocalizedString("newChallenge.pickAColor", value: "Pick a color", comment: "Color picker section title")
        static let startChallenge = NSLocalizedString("newChallenge.startChallenge", value: "Start Challenge", comment: "Start challenge button")
        static let tipsForSuccess = NSLocalizedString("newChallenge.tipsForSuccess", value: "💡 Tips for Success", comment: "Tips section title")
        static let tipRealisticHabit = NSLocalizedString("newChallenge.tipRealisticHabit", value: "Choose a realistic daily habit", comment: "Tip text")
        static let tipBeSpecific = NSLocalizedString("newChallenge.tipBeSpecific", value: "Be specific about what counts as \"done\"", comment: "Tip text")
        static let tipPickTime = NSLocalizedString("newChallenge.tipPickTime", value: "Pick a time of day that works best", comment: "Tip text")
        static let tipMaxChallenges = NSLocalizedString("newChallenge.tipMaxChallenges", value: "You can run up to 3 challenges at once", comment: "Tip text")
        static let maxChallengesReached = NSLocalizedString("newChallenge.maxChallengesReached", value: "Maximum Challenges Reached", comment: "Alert title")
        static let maxChallengesMessage = NSLocalizedString("newChallenge.maxChallengesMessage", value: "You can have up to 3 active challenges at once. Please complete or delete an existing challenge first.", comment: "Alert message")
        static let ok = NSLocalizedString("newChallenge.ok", value: "OK", comment: "OK button")
        static let quickIdeaAccessibility = NSLocalizedString("newChallenge.quickIdeaAccessibility", value: "Quick idea: %@", comment: "Accessibility label for quick idea tag")
        
        // Tags
        enum Tags {
            static let dailyReading = NSLocalizedString("newChallenge.tags.dailyReading", value: "Daily Reading", comment: "Suggested tag")
            static let meditation = NSLocalizedString("newChallenge.tags.meditation", value: "Meditation", comment: "Suggested tag")
            static let tenKSteps = NSLocalizedString("newChallenge.tags.tenKSteps", value: "10k Steps", comment: "Suggested tag")
            static let morningWorkout = NSLocalizedString("newChallenge.tags.morningWorkout", value: "Morning Workout", comment: "Suggested tag")
            static let journaling = NSLocalizedString("newChallenge.tags.journaling", value: "Journaling", comment: "Suggested tag")
            static let yoga = NSLocalizedString("newChallenge.tags.yoga", value: "Yoga", comment: "Suggested tag")
            static let wholeFoods = NSLocalizedString("newChallenge.tags.wholeFoods", value: "Whole Foods", comment: "Suggested tag")
            static let coding = NSLocalizedString("newChallenge.tags.coding", value: "Coding", comment: "Suggested tag")
            static let learnEnglish = NSLocalizedString("newChallenge.tags.learnEnglish", value: "Learn English", comment: "Suggested tag")
            
            static var all: [String] {
                [
                    dailyReading,
                    meditation,
                    tenKSteps,
                    morningWorkout,
                    journaling,
                    yoga,
                    wholeFoods,
                    coding,
                    learnEnglish
                ]
            }
        }
        
        static func quickIdeaAccessibilityLabel(_ tag: String) -> String {
            String(format: quickIdeaAccessibility, tag)
        }
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static let continueButton = NSLocalizedString("onboarding.continueButton", value: "Continue", comment: "Continue button on onboarding")
        static let getStarted = NSLocalizedString("onboarding.getStarted", value: "Get Started", comment: "Get started button on onboarding")
        
        enum Slides {
            static let goalTitle = NSLocalizedString("onboarding.slides.goalTitle", value: "Set Your Goal", comment: "Onboarding slide 1 title")
            static let goalDescription = NSLocalizedString("onboarding.slides.goalDescription", value: "Choose a habit to focus on.\nAnything that truly matters to you.", comment: "Onboarding slide 1 description")
            static let progressTitle = NSLocalizedString("onboarding.slides.progressTitle", value: "Track Your Progress", comment: "Onboarding slide 2 title")
            static let progressDescription = NSLocalizedString("onboarding.slides.progressDescription", value: "Mark each completed day\nand watch your progress grow.", comment: "Onboarding slide 2 description")
            static let consistencyTitle = NSLocalizedString("onboarding.slides.consistencyTitle", value: "Build Consistency", comment: "Onboarding slide 3 title")
            static let consistencyDescription = NSLocalizedString("onboarding.slides.consistencyDescription", value: "Small steps every day lead\nto lasting change.", comment: "Onboarding slide 3 description")
        }
    }
    
    // MARK: - Settings
    enum Settings {
        static let title = NSLocalizedString("settings.title", value: "Settings", comment: "Settings screen title")
        static let accountSection = NSLocalizedString("settings.accountSection", value: "ACCOUNT", comment: "Account section header")
        static let profile = NSLocalizedString("settings.profile", value: "Profile", comment: "Profile settings row")
        static let notifications = NSLocalizedString("settings.notifications", value: "Notifications", comment: "Notifications settings row")
        static let yourChallengesSection = NSLocalizedString("settings.yourChallengesSection", value: "YOUR CHALLENGES", comment: "Your challenges section header")
        static let supportSection = NSLocalizedString("settings.supportSection", value: "SUPPORT", comment: "Support section header")
        static let helpCenter = NSLocalizedString("settings.helpCenter", value: "Help Center", comment: "Help Center settings row")
        static let privacyPolicy = NSLocalizedString("settings.privacyPolicy", value: "Privacy Policy", comment: "Privacy Policy settings row")
        static func version(_ version: String) -> String {
            let format = NSLocalizedString("settings.version", value: "Version %@", comment: "App version string")
            return String(format: format, version)
        }
        static let deleteChallengeTitle = NSLocalizedString("settings.deleteChallengeTitle", value: "Delete Challenge?", comment: "Delete challenge alert title")
        static let delete = NSLocalizedString("settings.delete", value: "Delete", comment: "Delete button")
        static func deleteChallengeMessage(_ challengeTitle: String) -> String {
            let format = NSLocalizedString("settings.deleteChallengeMessage", value: "This will permanently delete \"%@\" and all progress. This action cannot be undone.", comment: "Delete challenge alert message")
            return String(format: format, challengeTitle)
        }
        static func challengeProgress(_ completed: Int) -> String {
            let format = NSLocalizedString("settings.challengeProgress", value: "%d / 100 days", comment: "Challenge progress in settings")
            return String(format: format, completed)
        }
    }
}
