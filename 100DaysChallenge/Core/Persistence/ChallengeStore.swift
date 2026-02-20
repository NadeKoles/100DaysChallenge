//
//  ChallengeStore.swift
//  100DaysChallenge
//
//  Local persistence using Core Data.
//

import Combine
import CoreData
import Foundation
import os

private let logger = Logger(subsystem: "com.nadekoles.100DaysChallenge.persistence", category: "CoreData")

@MainActor
class ChallengeStore: ObservableObject {
    static let shared = ChallengeStore(context: PersistenceController.shared.viewContext)
    static let maxChallenges = 3

    @Published private(set) var challenges: [Challenge] = []

    private let context: NSManagedObjectContext

    private init(context: NSManagedObjectContext) {
        self.context = context
        loadChallenges()
    }

    /// Preview store with sample challenges. Uses in-memory persistence.
    static func previewWithSamples() -> ChallengeStore {
        let store = ChallengeStore(context: PersistenceController.preview.viewContext)
        let sample1 = Challenge(
            title: "Daily Meditation",
            accentColor: "#4A90E2",
            startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            completedDaysSet: Set(1 ... 15)
        )
        let sample2 = Challenge(
            title: "Morning Exercise",
            accentColor: "#50C878",
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            completedDaysSet: Set([1, 2, 3, 5])
        )
        _ = store.addChallenge(sample1)
        _ = store.addChallenge(sample2)
        return store
    }

    /// Empty preview store.
    static func previewEmpty() -> ChallengeStore {
        ChallengeStore(context: PersistenceController.preview.viewContext)
    }

    // MARK: - Load

    func loadChallenges() {
        let request = ChallengeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ChallengeEntity.startDate, ascending: true)]
        do {
            let entities = try context.fetch(request)
            challenges = entities.compactMap { $0.toChallenge() }
        } catch {
            challenges = []
        }
    }

    // MARK: - Save

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            logger.error("Failed to save challenges: \(error.localizedDescription)")
        }
    }

    // MARK: - Add Challenge

    func addChallenge(_ challenge: Challenge) -> Bool {
        guard challenges.count < Self.maxChallenges else {
            return false
        }
        let entity = ChallengeEntity(context: context)
        entity.update(from: challenge)
        save()
        loadChallenges()
        return true
    }

    // MARK: - Update Challenge

    func updateChallenge(_ challenge: Challenge) {
        guard let entity = fetchEntity(id: challenge.id) else { return }
        entity.update(from: challenge)
        save()
        loadChallenges()
    }

    // MARK: - Delete Challenge

    func deleteChallenge(id: String) {
        guard let entity = fetchEntity(id: id) else { return }
        context.delete(entity)
        save()
        loadChallenges()
    }

    // MARK: - Toggle Day

    func toggleDay(challengeId: String, day: Int) {
        guard var challenge = challenges.first(where: { $0.id == challengeId }) else { return }
        if challenge.completedDaysSet.contains(day) {
            challenge.completedDaysSet.remove(day)
        } else {
            challenge.completedDaysSet.insert(day)
        }
        updateChallenge(challenge)
    }

    // MARK: - Complete Day

    func completeDay(challengeId: String, day: Int) {
        guard var challenge = challenges.first(where: { $0.id == challengeId }) else { return }
        challenge.completedDaysSet.insert(day)
        updateChallenge(challenge)
    }

    // MARK: - Private

    private func fetchEntity(id: String) -> ChallengeEntity? {
        let request = ChallengeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
