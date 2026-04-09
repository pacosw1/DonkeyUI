import XCTest
@testable import DonkeyUI

final class DonkeyDiagnosticsReporterTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.requestHandler = nil
        super.tearDown()
    }

    func testReportPerformanceIncludesBreadcrumbsAndHeaders() async throws {
        let expectation = expectation(description: "diagnostics request")

        URLProtocolStub.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/api/v1/diagnostics/events")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-123")

            let body = try XCTUnwrap(request.donkeyHTTPBodyData())
            let payload = try JSONDecoder().decode(DonkeyDiagnosticsPayload.self, from: body)

            XCTAssertEqual(payload.type, .performance)
            XCTAssertEqual(payload.category, "sync_duration")
            XCTAssertEqual(payload.platform, "ios")
            XCTAssertEqual(payload.installationID, "installation-1")
            XCTAssertEqual(payload.breadcrumbs.last?.category, "screen_view")
            XCTAssertEqual(payload.breadcrumbs.last?.message, "Home")
            XCTAssertEqual(payload.metadata["duration_ms"], "2300")

            expectation.fulfill()

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let reporter = makeReporter()
        await reporter.trackScreen("Home")
        await reporter.reportPerformance(category: "sync_duration", durationMs: 2300)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func testMarkLaunchReportsPreviousRunUnexpectedExit() async throws {
        let expectation = expectation(description: "previous run crash event")
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "DonkeyDiagnosticsReporterTests.\(UUID().uuidString)"))
        let keyPrefix = "diagnostics.test"

        defaults.set(true, forKey: "\(keyPrefix).active-run")
        defaults.set(Date(timeIntervalSince1970: 1_700_000_000), forKey: "\(keyPrefix).active-run-at")
        defaults.set("session-old", forKey: "\(keyPrefix).session-id")
        let breadcrumbs = [
            DonkeyDiagnosticBreadcrumb(category: "screen_view", message: "Chat")
        ]
        defaults.set(try JSONEncoder().encode(breadcrumbs), forKey: "\(keyPrefix).breadcrumbs")

        URLProtocolStub.requestHandler = { request in
            let body = try XCTUnwrap(request.donkeyHTTPBodyData())
            let payload = try JSONDecoder().decode(DonkeyDiagnosticsPayload.self, from: body)

            XCTAssertEqual(payload.type, .crash)
            XCTAssertEqual(payload.category, "previous_run_unexpected_exit")
            XCTAssertEqual(payload.sessionID, "session-old")
            XCTAssertEqual(payload.breadcrumbs.first?.message, "Chat")

            expectation.fulfill()

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let reporter = makeReporter(defaults: defaults, keyPrefix: keyPrefix)
        await reporter.markLaunch()

        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertFalse(defaults.string(forKey: "\(keyPrefix).session-id") == "session-old")
    }

    private func makeReporter(
        defaults: UserDefaults? = nil,
        keyPrefix: String = "donkey.diagnostics.tests"
    ) -> DonkeyDiagnosticsReporter {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        return DonkeyDiagnosticsReporter(
            baseURL: URL(string: "https://example.com")!,
            session: session,
            defaults: defaults ?? .standard,
            keyPrefix: keyPrefix,
            headersProvider: {
                [
                    "Authorization": "Bearer token-123",
                ]
            },
            installationIDProvider: {
                "installation-1"
            }
        )
    }
}

private extension URLRequest {
    func donkeyHTTPBodyData() -> Data? {
        if let httpBody {
            return httpBody
        }

        guard let httpBodyStream else {
            return nil
        }

        httpBodyStream.open()
        defer {
            httpBodyStream.close()
        }

        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }

        while httpBodyStream.hasBytesAvailable {
            let read = httpBodyStream.read(buffer, maxLength: bufferSize)
            if read <= 0 {
                break
            }
            data.append(buffer, count: read)
        }

        return data.isEmpty ? nil : data
    }
}

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = URLProtocolStub.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "URLProtocolStub", code: 0))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
