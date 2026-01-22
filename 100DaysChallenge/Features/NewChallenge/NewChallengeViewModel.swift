//
//  NewChallengeViewModel.swift
//  100DaysChallenge
//
//  ViewModel for new challenge screen
//

import SwiftUI

@MainActor
class NewChallengeViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var selectedColorIndex: Int = 0
    
    var selectedColor: Color {
        ChallengeAccentColor.all[selectedColorIndex].color
    }
    
    var selectedColorHex: String {
        ChallengeAccentColor.all[selectedColorIndex].hex
    }
    
    var isValid: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= 100
    }
    
    func reset() {
        title = ""
        selectedColorIndex = 0
    }
}

