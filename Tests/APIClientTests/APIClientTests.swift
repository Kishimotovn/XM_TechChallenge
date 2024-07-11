import XCTest
@testable import APIClient
import ComposableArchitecture
import XCTestDebugSupport
import ConfigConstant

final class APIClientTests: XCTestCase {
    func testGetQuestionsRequestFormat() async throws {
        try await withDependencies {
            let mockConfiguration = URLSessionConfiguration.ephemeral
            mockConfiguration.protocolClasses = [MockURLProtocol.self]
            $0.urlSession = URLSession(configuration: mockConfiguration)
            $0[ConfigConstant.self].overrideGetConfig(with: ConfigPlist.init(apiBaseURL: "http://test.com"))
        } operation: {
            let client = APIClient.live
            let targetRequestData = RequestData("questions")
            let targetRequest = try targetRequestData.urlRequest(given: "http://test.com")
            let expectation = XCTestExpectation(description: "request intercept expected")
            let expectedHeaders: [String: String] = [:]
            MockURLProtocol.requestHandler = { request in
                XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
                self.XCTAssertEqualURLs(targetRequest.url, request.url)
                XCTAssertEqual(nil, request.httpBodyStream?.readfully())
                XCTAssertEqual(targetRequest.httpMethod, request.httpMethod)
                expectation.fulfill()
                return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
            }
            _ = try? await client.getQuestions()
        }
    }
    
    func testSubmitQuestionRequestFormat() async throws {
        try await withDependencies {
            let mockConfiguration = URLSessionConfiguration.ephemeral
            mockConfiguration.protocolClasses = [MockURLProtocol.self]
            $0.urlSession = URLSession(configuration: mockConfiguration)
            $0[ConfigConstant.self].overrideGetConfig(with: ConfigPlist.init(apiBaseURL: "http://test.com"))
        } operation: {
            let client = APIClient.live
            let questionID = 1
            let answer = "answer"
            let input = SubmitQuestionInput(id: questionID, answer: answer)
            let targetRequestData = try RequestData(
                "question/submit",
                httpMethod: .post,
                jsonBody: input
            )
            let targetRequest = try targetRequestData.urlRequest(given: "http://test.com")
            let expectation = XCTestExpectation(description: "request intercept expected")
            let expectedHeaders: [String: String] = [
                "Content-Length": "26",
                "Content-Type": "application/json"
            ]
            MockURLProtocol.requestHandler = { request in
                XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
                self.XCTAssertEqualURLs(targetRequest.url, request.url)
                let body = request.httpBodyStream!.readfully()
                let decoder = JSONDecoder()
                let requestInput = try! decoder.decode(SubmitQuestionInput.self, from: body)
                XCTAssertEqual(input, requestInput)
                XCTAssertEqual(targetRequest.httpMethod, request.httpMethod)
                expectation.fulfill()
                return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
            }
            _ = try? await client.submitQuestion(questionID, answer)
        }
    }
    
    private func XCTAssertEqualURLs(_ url1: URL?, _ url2: URL?, file: StaticString = #file, line: UInt = #line) {
        guard let url1 = url1, let url2 = url2 else {
            return XCTFail("One or both URLs are nil", file: file, line: line)
        }
        
        guard let components1 = URLComponents(url: url1, resolvingAgainstBaseURL: false),
              let components2 = URLComponents(url: url2, resolvingAgainstBaseURL: false) else {
            return XCTFail("Could not create URLComponents from URLs", file: file, line: line)
        }
        
        guard components1.scheme == components2.scheme,
              components1.host == components2.host,
              components1.path == components2.path,
              components1.port == components2.port else {
            return XCTFail("URL components do not match", file: file, line: line)
        }
        
        // Sort query items by name (and value if names are equal) before comparison
        let queryItems1 = components1.queryItems?.sorted(by: {
            $0.name < $1.name || ($0.name == $1.name && $0.value ?? "" < $1.value ?? "")
        })
        let queryItems2 = components2.queryItems?.sorted(by: {
            $0.name < $1.name || ($0.name == $1.name && $0.value ?? "" < $1.value ?? "")
        })
        
        XCTAssertEqual(queryItems1, queryItems2, "Query items do not match", file: file, line: line)
    }
}

extension SubmitQuestionInput: Decodable, Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.answer == rhs.answer
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case answer
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let answer = try container.decode(String.self, forKey: .answer)
        self.init(id: id, answer: answer)
    }
}

extension InputStream {
    func readfully() -> Data {
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        open()
        
        var amount = 0
        repeat {
            amount = read(&buffer, maxLength: buffer.count)
            if amount > 0 {
                result.append(buffer, count: amount)
            }
        } while amount > 0
        
        close()
        
        return result
    }
}

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler is not set.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
}
