//
//  ChallengeStore.swift
//  100DaysChallenge
//
//  Local persistence (Core Data) with optional cloud sync (Firestore).
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
    private let firestoreRepository = FirestoreChallengeRepository()
    private(set) var currentUserId: String?
    private var hasPerformedInitialSync = false

    private init(context: NSManagedObjectContext) {
        self.context = context
        self.currentUserId = nil
        loadChallenges()
    }

    static func previewWithSamples() -> ChallengeStore {
        let store = ChallengeStore(context: PersistenceController.preview.viewContext)
        let colorOptions = ChallengeAccentColor.all
        let sample1 = Challenge(
            title: LocalizedStrings.Preview.sampleChallenge1Title,
            accentColor: colorOptions[0].hex,
            startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            completedDaysSet: Set(1 ... 15)
        )
        let sample2 = Challenge(
            title: LocalizedStrings.Preview.sampleChallenge2Title,
            accentColor: colorOptions[1].hex,
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            completedDaysSet: Set([1, 2, 3, 5])
        )
        _ = store.addChallenge(sample1)
        _ = store.addChallenge(sample2)
        return store
    }

    static func previewEmpty() -> ChallengeStore {
        ChallengeStore(context: PersistenceController.preview.viewContext)
    }

    static func previewWithOneChallenge() -> ChallengeStore {
        let store = ChallengeStore(context: PersistenceController.preview.viewContext)
        let sample = Challenge(
            title: LocalizedStrings.Preview.sampleChallenge1Title,
            accentColor: ChallengeAccentColor.all[0].hex,
            startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            completedDaysSet: Set([1])
        )
        _ = store.addChallenge(sample)
        return store
    }

    // Call when auth state changes. Loads challenges for the given user (nil = legacy/anonymous).
    // When switching to a signed-in user, runs initial cloud sync once per login session.
    func switchToUser(_ userId: String?) {
        guard currentUserId != userId else { return }
        hasPerformedInitialSync = false
        currentUserId = userId
        loadChallenges()

        if let uid = userId {
            performInitialSync(userId: uid)
        }
    }

    func loadChallenges() {
        let request = ChallengeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ChallengeEntity.startDate, ascending: true)]
        if let uid = currentUserId {
            request.predicate = NSPredicate(format: "userId == %@", uid)
        } else {
            request.predicate = NSPredicate(format: "userId == nil")
        }
        do {
            let entities = try context.fetch(request)
            challenges = entities.compactMap { $0.toChallenge() }
        } catch {
            logger.error("Failed to fetch challenges: \(error.localizedDescription)")
            challenges = []
        }
    }

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            logger.error("Failed to save challenges: \(error.localizedDescription)")
        }
    }

    func addChallenge(_ challenge: Challenge) -> Bool {
        guard challenges.count < Self.maxChallenges else {
            return false
        }
        let entity = ChallengeEntity(context: context)
        entity.update(from: challenge)
        entity.userId = currentUserId
        save()
        loadChallenges()
        return true
    }

    func updateChallenge(_ challenge: Challenge) {
        guard let entity = fetchEntity(id: challenge.id) else { return }
        entity.update(from: challenge)
        save()
        loadChallenges()
    }

    func deleteChallenge(id: String) {
        guard let entity = fetchEntity(id: id) else { return }
        context.delete(entity)
        save()
        loadChallenges()
    }

    func toggleDay(challengeId: String, day: Int) {
        guard var challenge = challenges.first(where: { $0.id == challengeId }) else { return }
        if challenge.completedDaysSet.contains(day) {
            challenge.completedDaysSet.remove(day)
        } else {
            challenge.completedDaysSet.insert(day)
        }
        updateChallenge(challenge)
    }

    func completeDay(challengeId: String, day: Int) {
        guard var challenge = challenges.first(where: { $0.id == challengeId }) else { return }
        challenge.completedDaysSet.insert(day)
        updateChallenge(challenge)
    }

    // MARK: - Initial Cloud Sync

    /// Runs once per login when switching to a signed-in user. Merges local and remote.
    private func performInitialSync(userId: String) {
        firestoreRepository.fetchChallenges { [weak self] result in
            guard let self else { return }
            guard self.currentUserId == userId else { return }
            switch result {
            case .success(let remote):
                let local = self.challenges
                if remote.isEmpty && !local.isEmpty {
                    self.uploadLocalToFirestore(local) {
                        if self.currentUserId == userId {
                            self.hasPerformedInitialSync = true
                        }
                    }
                } else if !remote.isEmpty {
                    self.replaceLocalWithRemote(remote)
                    self.hasPerformedInitialSync = true
                    self.loadChallenges()
                } else {
                    self.hasPerformedInitialSync = true
                }
            case .failure(let error):
                logger.error("Initial sync failed: \(error.localizedDescription)")
            }
        }
    }

    /// Uploads all local challenges to Firestore. Used when remote is empty (new account or reinstall).
    private func uploadLocalToFirestore(_ local: [Challenge], completion: @escaping () -> Void) {
        guard !local.isEmpty else {
            completion()
            return
        }
        var remaining = local.count
        for challenge in local {
            firestoreRepository.saveChallenge(challenge) { _ in
                remaining -= 1
                if remaining == 0 {
                    completion()
                }
            }
        }
    }

    /// Replaces all Core Data challenges for current user with remote data.
    private func replaceLocalWithRemote(_ remote: [Challenge]) {
        deleteAllEntitiesForCurrentUser()
        for challenge in remote {
            let entity = ChallengeEntity(context: context)
            entity.update(from: challenge)
            entity.userId = currentUserId
        }
        save()
    }

    private func deleteAllEntitiesForCurrentUser() {
        let request = ChallengeEntity.fetchRequest()
        if let uid = currentUserId {
            request.predicate = NSPredicate(format: "userId == %@", uid)
        } else {
            request.predicate = NSPredicate(format: "userId == nil")
        }
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            save()
        } catch {
            logger.error("Failed to delete local challenges: \(error.localizedDescription)")
        }
    }

    private func fetchEntity(id: String) -> ChallengeEntity? {
        let request = ChallengeEntity.fetchRequest()
        var format = "id == %@"
        var args: [Any] = [id]
        if let uid = currentUserId {
            format += " AND userId == %@"
            args.append(uid)
        } else {
            format += " AND userId == nil"
        }
        request.predicate = NSPredicate(format: format, argumentArray: args)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
