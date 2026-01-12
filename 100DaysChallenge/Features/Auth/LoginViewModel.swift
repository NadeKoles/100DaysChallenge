//
//  LoginViewModel.swift
//  100DaysChallenge
//
//  ViewModel for login screen
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }
    
    func login(completion: @escaping () -> Void) {
        // In a real app, this would make an API call
        // For now, just complete the flow
        completion()
    }
}

