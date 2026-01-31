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
    
    static var allSlides: [OnboardingSlide] {
        [
            OnboardingSlide(
                iconName: "target",
                title: LocalizedStrings.Onboarding.Slides.goalTitle,
                description: LocalizedStrings.Onboarding.Slides.goalDescription,
                color: .onboardingSunsetOrange
            ),
            OnboardingSlide(
                iconName: "chart.line.uptrend.xyaxis",
                title: LocalizedStrings.Onboarding.Slides.progressTitle,
                description: LocalizedStrings.Onboarding.Slides.progressDescription,
                color: .onboardingGreen
            ),
            OnboardingSlide(
                iconName: "sparkles",
                title: LocalizedStrings.Onboarding.Slides.consistencyTitle,
                description: LocalizedStrings.Onboarding.Slides.consistencyDescription,
                color: .onboardingBlue
            )
        ]
    }
    
    let slides: [OnboardingSlide] = OnboardingViewModel.allSlides
}

