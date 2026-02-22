//
//  PersistenceController.swift
//  100DaysChallenge
//
//  Persistence controller for Core Data.
//

import CoreData
import os

private let logger = Logger(subsystem: "com.nadekoles.100DaysChallenge.persistence", category: "CoreData")

struct PersistenceController {
    static let shared = PersistenceController(inMemory: false)
    static let preview = PersistenceController(inMemory: true)

    let container: NSPersistentContainer

    init(inMemory: Bool) {
        let container = NSPersistentContainer(name: "DaysChallengeModel")
        if inMemory, let description = container.persistentStoreDescriptions.first {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                logger.error("Core Data failed to load: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    Self.migrateChallengesFromUserDefaultsIfNeeded(container: container)
                }
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.container = container
    }

    private static func migrateChallengesFromUserDefaultsIfNeeded(container: NSPersistentContainer) {
        let defaults = UserDefaults.standard
        let challengesKey = "challenges"

        guard let data = defaults.data(forKey: challengesKey),
              let decoded = try? JSONDecoder().decode([Challenge].self, from: data) else {
            return
        }

        var seenIds = Set<String>()
        let uniqueDecoded = decoded.filter { seenIds.insert($0.id).inserted }

        let context = container.viewContext
        let existingIds: Set<String> = (try? context.fetch(ChallengeEntity.fetchRequest()))
            .map { Set($0.compactMap(\.id)) } ?? []

        let toInsert = uniqueDecoded.filter { !existingIds.contains($0.id) }
        for challenge in toInsert {
            let entity = ChallengeEntity(context: context)
            entity.update(from: challenge)
        }

        do {
            try context.save()
            defaults.removeObject(forKey: challengesKey)
        } catch {
            logger.error("Failed to migrate challenges from UserDefaults: \(error.localizedDescription)")
        }
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}
