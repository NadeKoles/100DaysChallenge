//
//  ChallengeStore.swift
//  100DaysChallenge
//
//  Local persistence using UserDefaults
//

import Foundation
import Combine

@MainActor
class ChallengeStore: ObservableObject {
    static let shared = ChallengeStore()
    
    @Published var challenges: [Challenge] = []
    
    private let maxChallenges = 3
    private let userDefaultsKey = "challenges"
    
    private init() {
        loadChallenges()
    }
    
    // MARK: - Load
    func loadChallenges() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([Challenge].self, from: data) else {
            challenges = []
            return
        }
        challenges = decoded
    }
    
    // MARK: - Save
    private func saveChallenges() {
        guard let encoded = try? JSONEncoder().encode(challenges) else {
            return
        }
        UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
    }
    
    // MARK: - Add Challenge
    func addChallenge(_ challenge: Challenge) -> Bool {
        guard challenges.count < maxChallenges else {
            return false
        }
        challenges.append(challenge)
        saveChallenges()
        return true
    }
    
    // MARK: - Update Challenge
    func updateChallenge(_ challenge: Challenge) {
        guard let index = challenges.firstIndex(where: { $0.id == challenge.id }) else {
            return
        }
        challenges[index] = challenge
        saveChallenges()
    }
    
    // MARK: - Delete Challenge
    func deleteChallenge(id: String) {
        challenges.removeAll { $0.id == id }
        saveChallenges()
    }
    
    // MARK: - Toggle Day
    func toggleDay(challengeId: String, day: Int) {
        guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else {
            return
        }
        
        var challenge = challenges[index]
        if challenge.completedDaysSet.contains(day) {
            challenge.completedDaysSet.remove(day)
        } else {
            challenge.completedDaysSet.insert(day)
        }
        challenges[index] = challenge
        saveChallenges()
    }
    
    // MARK: - Complete Day
    func completeDay(challengeId: String, day: Int) {
        guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else {
            return
        }
        
        var challenge = challenges[index]
        challenge.completedDaysSet.insert(day)
        challenges[index] = challenge
        saveChallenges()
    }
}

