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
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.container = container
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}
