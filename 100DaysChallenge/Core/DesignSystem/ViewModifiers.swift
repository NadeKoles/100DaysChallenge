//
//  ViewModifiers.swift
//  100DaysChallenge
//
//  Reusable view modifiers for consistent styling
//

import SwiftUI

extension View {
    // MARK: - Error Alert
    func errorAlert(_ errorMessage: Binding<String?>) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { errorMessage.wrappedValue != nil },
            set: { if !$0 { errorMessage.wrappedValue = nil } }
        )) {
            Button("OK") {
                errorMessage.wrappedValue = nil
            }
        } message: {
            if let message = errorMessage.wrappedValue {
                Text(message)
            }
        }
    }
}
