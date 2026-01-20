//
//  OnboardingViewModel.swift
//  100DaysChallenge
//
//  ViewModel for onboarding flow
//

import SwiftUI

struct OnboardingSlide {
    let iconName: String
    let title: String
    let description: String
    let color: Color
}

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentSlide: Int = 0
    
    static let allSlides: [OnboardingSlide] = [
        OnboardingSlide(
            iconName: "target",
            title: "Set Your Goal",
            description: "Choose a habit to focus on.\nAnything that truly matters to you.",
            color: .onboardingSunsetOrange
        ),
        OnboardingSlide(
            iconName: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Mark each completed day\nand watch your progress grow.",
            color: .onboardingGreen
        ),
        OnboardingSlide(
            iconName: "sparkles",
            title: "Build Consistency",
            description: "Small steps every day lead\nto lasting change.",
            color: .onboardingBlue
        )
    ]
    
    let slides: [OnboardingSlide] = OnboardingViewModel.allSlides
}

