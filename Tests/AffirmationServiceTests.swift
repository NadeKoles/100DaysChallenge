//
//  AffirmationServiceTests.swift
//  100DaysChallengeTests
//
//  Unit tests for AffirmationService: success, non-2xx, bad JSON, transport error.
//

import XCTest
@testable import _00DaysChallenge   // product module name 

final class AffirmationServiceTests: XCTestCase {

    private struct MockHTTPClient: HTTPClient {
        let result: Result<(Data, URLResponse), Error>
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try result.get()
        }
    }

    private func httpResponse(_ code: Int) -> URLResponse {
        HTTPURLResponse(url: URL(string: "https://www.affirmations.dev/")!,
                        statusCode: code, httpVersion: nil, headerFields: nil)!
    }

    func testFetchAffirmation_success_decodesAffirmation() async throws {
        let json = #"{"affirmation":"You're doing great"}"#.data(using: .utf8)!
        let service = AffirmationService(client: MockHTTPClient(result: .success((json, httpResponse(200)))))

        let affirmation = try await service.fetchAffirmation()

        XCTAssertEqual(affirmation, Affirmation(text: "You're doing great"))
    }

    func testFetchAffirmation_non2xx_throwsInvalidResponse() async {
        let service = AffirmationService(client: MockHTTPClient(result: .success((Data(), httpResponse(500)))))
        await assertThrows(.invalidResponse) { _ = try await service.fetchAffirmation() }
    }

    func testFetchAffirmation_badJSON_throwsDecodingFailed() async {
        let bad = #"{"unexpected":true}"#.data(using: .utf8)!
        let service = AffirmationService(client: MockHTTPClient(result: .success((bad, httpResponse(200)))))
        await assertThrows(.decodingFailed) { _ = try await service.fetchAffirmation() }
    }

    func testFetchAffirmation_transportError_throwsTransport() async {
        let underlying = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        let service = AffirmationService(client: MockHTTPClient(result: .failure(underlying)))
        do {
            _ = try await service.fetchAffirmation()
            XCTFail("Expected an error")
        } catch let error as AffirmationServiceError {
            guard case .transport = error else { return XCTFail("Expected .transport, got \(error)") }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    private func assertThrows(_ expected: AffirmationServiceError,
                              _ block: () async throws -> Void,
                              file: StaticString = #filePath,
                              line: UInt = #line) async {
        do {
            try await block()
            XCTFail("Expected \(expected) but no error was thrown", file: file, line: line)
        } catch let error as AffirmationServiceError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }
}
