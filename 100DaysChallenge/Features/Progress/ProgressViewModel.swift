//
//  ProgressViewModel.swift
//  100DaysChallenge
//
//  ViewModel for progress view
//

import Foundation

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var currentChallengeId: String = ""
}

