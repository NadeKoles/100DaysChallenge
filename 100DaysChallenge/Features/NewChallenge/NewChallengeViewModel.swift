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
    @Published var selectedColor: Color = ChallengeAccentColor.all[0].color
    
    var selectedColorHex: String {
        // Convert Color to hex string
        // For simplicity, we'll use a mapping
        let colorMap: [Color: String] = [
            .accentCoralRed: "#FF6B6B",
            .accentSunsetOrange: "#FF9D5C",
            .accentSunnyYellow: "#FFD23F",
            .accentFreshGreen: "#6BCF94",
            .accentOceanTeal: "#4ECDC4",
            .accentSkyBlue: "#5C9FFF",
            .accentSoftLavender: "#C7B7FF",
            .accentRoyalPurple: "#9B6BFF",
            .accentMagenta: "#FF6BB5",
            .accentWarmBrown: "#76574A",
            .accentDeepNavy: "#1F2A44"
        ]
        return colorMap[selectedColor] ?? "#FF6B6B"
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func reset() {
        title = ""
        selectedColor = ChallengeAccentColor.all[0].color
    }
}

