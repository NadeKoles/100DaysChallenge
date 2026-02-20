//
//  ChallengeEntity+Challenge.swift
//  100DaysChallenge
//

import CoreData

extension ChallengeEntity {
    func toChallenge() -> Challenge? {
        guard let id = id else { return nil }
        let completedDays: Set<Int> = {
            guard let data = completedDaysData,
                  let array = try? JSONDecoder().decode([Int].self, from: data) else {
                return []
            }
            return Set(array)
        }()
        return Challenge(
            id: id,
            title: title ?? "",
            accentColor: accentColor ?? "",
            startDate: startDate ?? Date(),
            completedDaysSet: completedDays
        )
    }

    func update(from challenge: Challenge) {
        id = challenge.id
        title = challenge.title
        accentColor = challenge.accentColor
        startDate = challenge.startDate
        completedDaysData = try? JSONEncoder().encode(Array(challenge.completedDaysSet))
    }
}
