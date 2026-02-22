//
//  FirestoreChallengeDTO.swift
//  100DaysChallenge
//
//  DTO for Firestore documents. Uses manual encode/decode (no FirebaseFirestoreSwift).
//

import FirebaseFirestore
import Foundation

struct FirestoreChallengeDTO {
    let id: String
    let title: String
    let accentColor: String
    let startDate: Date
    let completedDays: [Int]

    private static let maxDay = 100

    init(from challenge: Challenge) {
        self.id = challenge.id
        self.title = challenge.title
        self.accentColor = challenge.accentColor
        self.startDate = challenge.startDate
        self.completedDays = Array(challenge.completedDaysSet)
    }

    // Builds domain model. Validates completedDays are in range 1...100.
    func toDomain() -> Challenge {
        let validDays = Set(completedDays.filter { (1...Self.maxDay).contains($0) })
        return Challenge(
            id: id,
            title: title,
            accentColor: accentColor,
            startDate: startDate,
            completedDaysSet: validDays
        )
    }

    // Encodes to Firestore-compatible dictionary (Date → Timestamp).
    func toFirestoreData() -> [String: Any] {
        [
            "id": id,
            "title": title,
            "accentColor": accentColor,
            "startDate": Timestamp(date: startDate),
            "completedDays": completedDays,
        ]
    }

    // Decodes from Firestore document data. Returns nil if required fields are missing or invalid.
    static func fromFirestoreData(_ data: [String: Any], documentId: String) -> FirestoreChallengeDTO? {
        guard let title = data["title"] as? String,
              let accentColor = data["accentColor"] as? String else {
            return nil
        }
        let completedDays: [Int] = (data["completedDays"] as? [Int]) ?? (data["completedDays"] as? [Int64])?.map(Int.init) ?? []
        let startDate: Date
        if let timestamp = data["startDate"] as? Timestamp {
            startDate = timestamp.dateValue()
        } else if let seconds = data["startDate"] as? Double {
            startDate = Date(timeIntervalSince1970: seconds)
        } else {
            return nil
        }
        return FirestoreChallengeDTO(
            id: documentId,
            title: title,
            accentColor: accentColor,
            startDate: startDate,
            completedDays: completedDays
        )
    }

    private init(id: String, title: String, accentColor: String, startDate: Date, completedDays: [Int]) {
        self.id = id
        self.title = title
        self.accentColor = accentColor
        self.startDate = startDate
        self.completedDays = completedDays
    }
}
