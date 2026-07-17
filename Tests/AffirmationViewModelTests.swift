//
//  AffirmationViewModelTests.swift
//  100DaysChallengeTests
//
//  Unit tests for AffirmationViewModel's caching logic: 12-hour refresh
//  throttle, cache fallback on network failure, and silent failure.
//

import XCTest
@testable import _00DaysChallenge   // product module name 

@MainActor
final class AffirmationViewModelTests: XCTestCase {

    // Mirrors AffirmationViewModel's private cache keys.
    private let textKey = "affirmation.cachedText"
    private let fetchedAtKey = "affirmation.fetchedAt"

    private let suiteName = "AffirmationViewModelTests"
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testLoad_noCache_fetchesAndCaches() async {
        let vm = AffirmationViewModel(service: service(returning: "Fresh"), defaults: defaults)

        await vm.load()

        XCTAssertEqual(vm.affirmation, Affirmation(text: "Fresh"))
        XCTAssertEqual(defaults.string(forKey: textKey), "Fresh")
        XCTAssertNotNil(defaults.object(forKey: fetchedAtKey) as? Date)
    }

    func testLoad_freshCache_usesCacheWithoutNetwork() async {
        seedCache(text: "Cached", age: 0)
        let vm = AffirmationViewModel(service: forbiddenNetworkService(), defaults: defaults)

        await vm.load()

        XCTAssertEqual(vm.affirmation, Affirmation(text: "Cached"))
    }

    func testLoad_staleCache_refetches() async {
        seedCache(text: "Old", age: 13 * 60 * 60) // older than the 12h window
        let vm = AffirmationViewModel(service: service(returning: "New"), defaults: defaults)

        await vm.load()

        XCTAssertEqual(vm.affirmation, Affirmation(text: "New"))
        XCTAssertEqual(defaults.string(forKey: textKey), "New")
    }

    func testLoad_networkFails_withCache_fallsBackToCache() async {
        seedCache(text: "Old", age: 13 * 60 * 60) // stale, so it attempts a fetch
        let vm = AffirmationViewModel(service: failingService(), defaults: defaults)

        await vm.load()

        XCTAssertEqual(vm.affirmation, Affirmation(text: "Old"))
        XCTAssertFalse(vm.loadFailed)
    }

    func testLoad_networkFails_noCache_setsLoadFailed() async {
        let vm = AffirmationViewModel(service: failingService(), defaults: defaults)

        await vm.load()

        XCTAssertNil(vm.affirmation)
        XCTAssertTrue(vm.loadFailed)
    }

    // MARK: - Helpers

    private func seedCache(text: String, age: TimeInterval) {
        defaults.set(text, forKey: textKey)
        defaults.set(Date(timeIntervalSinceNow: -age), forKey: fetchedAtKey)
    }

    private func service(returning text: String) -> AffirmationService {
        let json = #"{"affirmation":"\#(text)"}"#.data(using: .utf8)!
        return AffirmationService(client: StubClient(result: .success((json, okResponse()))))
    }

    private func failingService() -> AffirmationService {
        AffirmationService(client: StubClient(result: .failure(URLError(.notConnectedToInternet))))
    }

    private func forbiddenNetworkService() -> AffirmationService {
        AffirmationService(client: ForbiddenClient())
    }

    private func okResponse() -> URLResponse {
        HTTPURLResponse(url: URL(string: "https://www.affirmations.dev/")!,
                        statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

private struct StubClient: HTTPClient {
    let result: Result<(Data, URLResponse), Error>
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try result.get()
    }
}

private struct ForbiddenClient: HTTPClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        XCTFail("Network should not be called when the cache is fresh")
        throw URLError(.badServerResponse)
    }
}
