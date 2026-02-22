//
//  FirestoreChallengeRepository.swift
//  100DaysChallenge
//
//  Firestore cloud persistence. Path: users/{uid}/challenges/{challengeId}
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import os

private let logger = Logger(subsystem: "com.nadekoles.100DaysChallenge.persistence", category: "Firestore")

final class FirestoreChallengeRepository {

    private let db = Firestore.firestore()

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    private func challengesCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("challenges")
    }

    // MARK: - Fetch

    // Fetches challenges for the current user. Returns empty array if user is nil.
    func fetchChallenges(completion: @escaping (Result<[Challenge], Error>) -> Void) {
        guard let userId = currentUserId else {
            dispatchToMain(.success([]), completion: completion)
            return
        }

        challengesCollection(for: userId).getDocuments { [weak self] snapshot, error in
            if let error {
                logger.error("Firestore fetch failed: \(error.localizedDescription)")
                self?.dispatchToMain(.failure(error), completion: completion)
                return
            }

            guard let documents = snapshot?.documents else {
                self?.dispatchToMain(.success([]), completion: completion)
                return
            }

            var challenges: [Challenge] = []
            for doc in documents {
                let data = doc.data()
                guard let dto = FirestoreChallengeDTO.fromFirestoreData(data, documentId: doc.documentID) else {
                    logger.warning("Skipping malformed challenge document: \(doc.documentID)")
                    continue
                }
                challenges.append(dto.toDomain())
            }
            challenges.sort { $0.startDate < $1.startDate }
            self?.dispatchToMain(.success(challenges), completion: completion)
        }
    }

    // MARK: - Save

    // Saves a challenge. No-op if user is nil. Completion runs on main queue.
    func saveChallenge(_ challenge: Challenge, completion: ((Error?) -> Void)? = nil) {
        guard let userId = currentUserId else {
            dispatchToMain(nil, completion: completion)
            return
        }

        let dto = FirestoreChallengeDTO(from: challenge)
        challengesCollection(for: userId).document(challenge.id).setData(dto.toFirestoreData()) { [weak self] error in
            if let error {
                logger.error("Firestore save failed: \(error.localizedDescription)")
            }
            self?.dispatchToMain(error, completion: completion)
        }
    }

    // MARK: - Delete

    // Deletes a challenge. No-op if user is nil. Completion runs on main queue.
    func deleteChallenge(id: String, completion: ((Error?) -> Void)? = nil) {
        guard let userId = currentUserId else {
            dispatchToMain(nil, completion: completion)
            return
        }

        challengesCollection(for: userId).document(id).delete { [weak self] error in
            if let error {
                logger.error("Firestore delete failed: \(error.localizedDescription)")
            }
            self?.dispatchToMain(error, completion: completion)
        }
    }

    private func dispatchToMain<T>(_ value: T, completion: ((T) -> Void)?) {
        guard let completion else { return }
        if Thread.isMainThread {
            completion(value)
        } else {
            DispatchQueue.main.async { completion(value) }
        }
    }
}
