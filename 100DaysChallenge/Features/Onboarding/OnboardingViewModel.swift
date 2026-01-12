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
    
    let slides: [OnboardingSlide] = [
        OnboardingSlide(
            iconName: "target",
            title: "Set Your Goal",
            description: "Choose a habit you want to build. Reading, exercise, meditation—anything that matters to you.",
            color: .onboardingBlue
        ),
        OnboardingSlide(
            iconName: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Mark each day you complete your challenge. Watch your progress grow over 100 days.",
            color: .onboardingRed
        ),
        OnboardingSlide(
            iconName: "sparkles",
            title: "Build Consistency",
            description: "Small steps every day lead to lasting change. Stay motivated with visual progress.",
            color: .onboardingGreen
        )
    ]
}

