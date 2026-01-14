//
//  InputField.swift
//  100DaysChallenge
//
//  Reusable input field component
//

import SwiftUI
import UIKit

// MARK: - Email TextField Wrapper
struct EmailTextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var textColor: UIColor
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.textColor = textColor
        // Use design system font size (Font.body = 16pt)
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textContentType = .username
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textColor = textColor
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: EmailTextFieldWrapper
        init(_ parent: EmailTextFieldWrapper) {
            self.parent = parent
        }
        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
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
                    case .email:
                        EmailTextFieldWrapper(
                            text: $text,
                            placeholder: placeholder,
                            textColor: UIColor(Color.textSecondary)
                        )
                    case .password:
                        SecureField(placeholder, text: $text)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
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
