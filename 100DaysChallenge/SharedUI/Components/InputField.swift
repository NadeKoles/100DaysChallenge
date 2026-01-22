//
//  InputField.swift
//  100DaysChallenge
//
//  Reusable input field component
//

import SwiftUI
import UIKit

// MARK: - Input Limits
enum InputLimits {
    static let email = 254
    static let name = 50
    static let challengeTitle = 100
}

// MARK: - Email TextField Wrapper
struct EmailTextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var textColor: UIColor
    var maxLength: Int?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textColor = textColor
        textField.font = .body
        textField.textContentType = .username
        textField.borderStyle = .none
        textField.adjustsFontSizeToFitWidth = false
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        let textToSet: String
        if let maxLength = maxLength, text.count > maxLength {
            textToSet = String(text.prefix(maxLength))
            if textToSet != text {
                Task { @MainActor in
                    self.text = textToSet
                }
            }
        } else {
            textToSet = text
        }
        
        if uiView.text != textToSet {
            uiView.text = textToSet
        }
        uiView.textColor = textColor
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmailTextFieldWrapper
        init(_ parent: EmailTextFieldWrapper) {
            self.parent = parent
        }
        
        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let maxLength = parent.maxLength else { return true }
            
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            return newText.count <= maxLength
        }
    }
}

// MARK: - Input Field Type
enum InputFieldType {
    case text
    case email
    case password
}

struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let type: InputFieldType
    let iconName: String
    var maxLength: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(label)
                .font(.labelSmall)
                .foregroundColor(.textSecondary)
            
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.gray400)
                    .frame(width: 20)
                
                Group {
                    switch type {
                    case .text:
                        TextField(placeholder, text: $text)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                            .onChange(of: text) { newValue in
                                if let maxLength = maxLength, newValue.count > maxLength {
                                    text = String(newValue.prefix(maxLength))
                                }
                            }
                    case .email:
                        EmailTextFieldWrapper(
                            text: $text,
                            placeholder: placeholder,
                            textColor: UIColor(Color.textSecondary),
                            maxLength: maxLength
                        )
                        .frame(maxWidth: .infinity)
                        .layoutPriority(1)
                    case .password:
                        SecureField(placeholder, text: $text)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                            .onChange(of: text) { newValue in
                                if let maxLength = maxLength, newValue.count > maxLength {
                                    text = String(newValue.prefix(maxLength))
                                }
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
            .background(Color.inputBackground)
            .cornerRadius(CornerRadius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
    }
}
