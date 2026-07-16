//
//  AffirmationFeature.swift
//  100DaysChallenge
//
//  "Daily affirmation": fetches a short positive affirmation from a public REST API.
//

import Foundation
import SwiftUI
import os

private let logger = Logger(subsystem: "com.nadekoles.100DaysChallenge.network", category: "AffirmationService")

// MARK: - Model

struct Affirmation: Codable, Equatable {
    let text: String

    enum CodingKeys: String, CodingKey {
        case text = "affirmation"
    }
}

// MARK: - Errors

enum AffirmationServiceError: Error, Equatable {
    case invalidResponse
    case decodingFailed
    case transport(String)
}

// MARK: - HTTP Client

protocol HTTPClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPClient {}

// MARK: - Service

final class AffirmationService {
    private let client: HTTPClient
    private let url: URL

    init(client: HTTPClient = URLSession.shared,
         url: URL = URL(string: "https://www.affirmations.dev/")!) {
        self.client = client
        self.url = url
    }

    func fetchAffirmation() async throws -> Affirmation {
        let request = URLRequest(url: url)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await client.data(for: request)
        } catch {
            logger.error("Transport error: \(error.localizedDescription)")
            throw AffirmationServiceError.transport(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AffirmationServiceError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(Affirmation.self, from: data)
        } catch {
            logger.error("Decoding failed: \(error.localizedDescription)")
            throw AffirmationServiceError.decodingFailed
        }
    }
}

// MARK: - ViewModel

private let affirmationTextKey = "affirmation.cachedText"
private let affirmationFetchedAtKey = "affirmation.fetchedAt"

@MainActor
final class AffirmationViewModel: ObservableObject {
    @Published private(set) var affirmation: Affirmation?
    @Published private(set) var loadFailed = false

    private static let refreshInterval: TimeInterval = 12 * 60 * 60

    private let service: AffirmationService
    private let defaults: UserDefaults
    private var isFetching = false

    init(service: AffirmationService = AffirmationService(),
         defaults: UserDefaults = .standard) {
        self.service = service
        self.defaults = defaults
    }

    func load() async {
        if let cached = cachedAffirmation(),
           Date().timeIntervalSince(cached.fetchedAt) < Self.refreshInterval {
            affirmation = cached.affirmation
            return
        }

        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        loadFailed = false
        do {
            let fresh = try await service.fetchAffirmation()
            affirmation = fresh
            cache(fresh, at: Date())
        } catch {
            if let cached = cachedAffirmation() {
                affirmation = cached.affirmation
            } else {
                loadFailed = true
            }
        }
    }

    private func cachedAffirmation() -> (affirmation: Affirmation, fetchedAt: Date)? {
        guard let text = defaults.string(forKey: affirmationTextKey),
              let fetchedAt = defaults.object(forKey: affirmationFetchedAtKey) as? Date else {
            return nil
        }
        return (Affirmation(text: text), fetchedAt)
    }

    private func cache(_ affirmation: Affirmation, at date: Date) {
        defaults.set(affirmation.text, forKey: affirmationTextKey)
        defaults.set(date, forKey: affirmationFetchedAtKey)
    }
}

// MARK: - View

struct DailyAffirmationView: View {
    private enum Metrics {
        static let reservedHeight: CGFloat = 64
    }

    @ObservedObject var viewModel: AffirmationViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if let affirmation = viewModel.affirmation {
                Text(affirmation.text)
                    .font(.affirmation).italic()
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.lg)
                    .background(Color.gray50)
                    .cornerRadius(CornerRadius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .stroke(Color.border, lineWidth: 1)
                    )
            } else if viewModel.loadFailed {
                EmptyView()
            } else {
                Color.clear.frame(minHeight: Metrics.reservedHeight)
            }
        }
        .task { await viewModel.load() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await viewModel.load() }
            }
        }
    }
}
