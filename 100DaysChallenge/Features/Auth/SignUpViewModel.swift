//
//  SignUpViewModel.swift
//  100DaysChallenge
//
//  ViewModel for sign up screen
//

import Foundation

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }
    
    func signUp(completion: @escaping () -> Void) {
        // In a real app, this would make an API call
        // For now, just complete the flow
        completion()
    }
}

