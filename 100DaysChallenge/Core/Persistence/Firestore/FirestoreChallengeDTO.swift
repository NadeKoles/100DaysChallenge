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

    // Firestore may return integer arrays as [Int], [Int64], or [NSNumber].
    private static func parseCompletedDays(from value: Any?) -> [Int] {
        if let arr = value as? [Int] { return arr }
        if let arr = (value as? [Int64])?.map(Int.init) { return arr }
        if let arr = value as? [NSNumber] { return arr.map(\.intValue) }
        return []
    }

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
              !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let accentColor = data["accentColor"] as? String,
              !accentColor.isEmpty else {
            return nil
        }
        let completedDays = Self.parseCompletedDays(from: data["completedDays"])
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
