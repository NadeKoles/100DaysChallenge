//
//  ViewModifiers.swift
//  100DaysChallenge
//
//  Reusable view modifiers for consistent styling
//

import SwiftUI

extension View {
    // MARK: - Alert Modifiers
    func messageAlert(error: Binding<String?>, info: Binding<String?>) -> some View {
        let hasError = error.wrappedValue != nil
        let hasInfo = info.wrappedValue != nil
        let isPresented = hasError || hasInfo
        
        return self.alert(
            hasError ? "Error" : "Info",
            isPresented: Binding(
                get: { isPresented },
                set: { if !$0 {
                    error.wrappedValue = nil
                    info.wrappedValue = nil
                }}
            )
        ) {
            Button("OK") {
                error.wrappedValue = nil
                info.wrappedValue = nil
            }
        } message: {
            if let message = hasError ? error.wrappedValue : info.wrappedValue {
                Text(message)
            }
        }
    }
}
