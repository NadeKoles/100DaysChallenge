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
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                logger.error("Core Data failed to load: \(error.localizedDescription)")
            } else {
                Self.migrateChallengesFromUserDefaultsIfNeeded(container: container)
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

        let context = container.viewContext
        for challenge in decoded {
            let entity = ChallengeEntity(context: context)
            entity.id = challenge.id
            entity.title = challenge.title
            entity.accentColor = challenge.accentColor
            entity.startDate = challenge.startDate
            entity.completedDaysData = try? JSONEncoder().encode(Array(challenge.completedDaysSet))
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
