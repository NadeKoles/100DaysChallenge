//
//  ViewModifiers.swift
//  100DaysChallenge
//
//  Reusable view modifiers for consistent styling
//

import SwiftUI
import UIKit

// MARK: - Gradient Blur (UIKit-based, mask works reliably)
private final class GradientBlurHostView: UIView {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let maskLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        blurView.backgroundColor = .clear
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)

        maskLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(BottomActionBarLayout.gradientBlurMidAlpha).cgColor,
            UIColor.white.cgColor
        ]
        maskLayer.locations = BottomActionBarLayout.gradientBlurMaskLocations
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 1)
        blurView.layer.mask = maskLayer
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        maskLayer.frame = blurView.bounds
    }
}

private struct GradientBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> GradientBlurHostView {
        GradientBlurHostView()
    }

    func updateUIView(_ uiView: GradientBlurHostView, context: Context) {}
}

// MARK: - Bottom Action Bar
enum BottomActionBarLayout {
    static let scrollContentBottomMargin: CGFloat = 80
    static let gradientBlurHeight: CGFloat = 140
    static let gradientBlurMaskLocations: [NSNumber] = [0, 0.5, 0.8, 1].map { NSNumber(value: $0) }
    static let gradientBlurMidAlpha: CGFloat = 0.7
}

struct BottomActionBar<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .background(alignment: .bottom) {
            GradientBlurView()
                .frame(height: BottomActionBarLayout.gradientBlurHeight)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("BottomActionBar") {
    ZStack {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                ForEach(0..<2, id: \.self) { _ in
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.sm), GridItem(.flexible(), spacing: Spacing.sm)], spacing: Spacing.sm) {
                        ForEach(ChallengeAccentColor.all, id: \.name) { option in
                            RoundedRectangle(cornerRadius: CornerRadius.lg)
                                .fill(option.color)
                                .frame(height: 60)
                        }
                    }
                }
            }
            .padding(Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)

        BottomActionBar {
            PrimaryButton(
                title: "Mark Day 15 Complete",
                action: {},
                iconSystemNameLeft: "checkmark",
                style: .solid(.accentFreshGreen)
            )
        }
    }
}

// MARK: - Reset Password Prompt Model
struct ResetPasswordPrompt: Identifiable, Equatable {
    let id = UUID()
    var email: String
    var onSend: (String) -> Void
    
    // Compare id and email, ignore closure
    static func == (lhs: ResetPasswordPrompt, rhs: ResetPasswordPrompt) -> Bool {
        lhs.id == rhs.id && lhs.email == rhs.email
    }
}

extension View {
    // MARK: - Unified Auth Alerts
    func authAlerts(
        error: Binding<String?>,
        info: Binding<String?>,
        resetPrompt: Binding<ResetPasswordPrompt?>
    ) -> some View {
        self.modifier(AuthAlertsModifier(
            error: error,
            info: info,
            resetPrompt: resetPrompt
        ))
    }
    
    // MARK: - Section Header Style
    func sectionHeaderStyle() -> some View {
        self.modifier(SectionHeaderStyleModifier())
    }
}

// MARK: - Section Header Style Modifier
private struct SectionHeaderStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.labelTiny)
            .foregroundColor(.textTertiary)
            .tracking(1)
    }
}

// MARK: - Auth Alerts Modifier
private struct AuthAlertsModifier: ViewModifier {
    @Binding var error: String?
    @Binding var info: String?
    @Binding var resetPrompt: ResetPasswordPrompt?
    @State private var resetEmail: String = ""
    @State private var resetEmailError: String?
    @State private var shouldReopenResetPrompt = false
    
    private var isAlertPresented: Bool {
        resetPrompt != nil || error != nil || info != nil
    }
    
    private var alertTitle: String {
        if resetPrompt != nil {
            return LocalizedStrings.Auth.resetPasswordTitle
        } else if error != nil {
            return LocalizedStrings.Auth.errorTitle
        } else {
            return LocalizedStrings.Auth.infoTitle
        }
    }
    
    private var trimmedResetEmail: String {
        resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    func body(content: Content) -> some View {
        content
            .alert(
                alertTitle,
                isPresented: Binding(
                    get: { isAlertPresented },
                    set: { newValue in
                        if !newValue {
                            if shouldReopenResetPrompt && resetPrompt != nil {
                                // Reopen prompt after validation failure
                                if let currentPrompt = resetPrompt {
                                    Task { @MainActor in
                                        resetPrompt = nil
                                        await Task.yield()

                                        resetPrompt = ResetPasswordPrompt(
                                            email: currentPrompt.email,
                                            onSend: currentPrompt.onSend
                                        )
                                        shouldReopenResetPrompt = false
                                    }
                                }
                            } else {
                                resetPrompt = nil
                                error = nil
                                info = nil
                            }
                        }
                    }
                )
            ) {
                if resetPrompt != nil {
                    TextField(LocalizedStrings.Auth.emailPlaceholder, text: $resetEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: resetEmail) {
                            resetEmailError = nil
                        }
                    
                    Button(LocalizedStrings.Auth.cancel, role: .cancel) {
                        resetPrompt = nil
                        resetEmailError = nil
                        shouldReopenResetPrompt = false
                    }
                    
                    Button(LocalizedStrings.Auth.send) {
                        guard let prompt = resetPrompt else { return }
                        
                        let normalized = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        guard !normalized.isEmpty else {
                            return
                        }
                        
                        guard AuthViewModel.isValidEmail(normalized) else {
                            resetEmailError = LocalizedStrings.Auth.invalidEmail
                            shouldReopenResetPrompt = true
                            return
                        }
                        
                        resetEmailError = nil
                        shouldReopenResetPrompt = false
                        prompt.onSend(normalized)
                        resetPrompt = nil
                    }
                    .disabled(trimmedResetEmail.isEmpty)
                } else {
                    Button(LocalizedStrings.Auth.ok) {
                        error = nil
                        info = nil
                    }
                }
            } message: {
                if resetPrompt != nil {
                    if let resetEmailError = resetEmailError {
                        Text(resetEmailError)
                            .foregroundStyle(.red)
                            .font(.callout)
                    } else {
                        Text(LocalizedStrings.Auth.resetPasswordMessage)
                    }
                } else if let errorMessage = error {
                    Text(errorMessage)
                } else if let infoMessage = info {
                    Text(infoMessage)
                }
            }
            .onChange(of: resetPrompt) { _, newValue in
                if let prompt = newValue {
                    // Preserve error state when reopening after validation failure
                    if resetEmailError == nil {
                        resetEmail = prompt.email
                        resetEmailError = nil
                        shouldReopenResetPrompt = false
                    }
                } else {
                    resetEmail = ""
                    resetEmailError = nil
                    shouldReopenResetPrompt = false
                }
            }
    }
}
