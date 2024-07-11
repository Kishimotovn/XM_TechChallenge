import Foundation
import ComposableArchitecture

actor RestClient {
    let baseURL: any URLConvertible
    
    init(baseURL: any URLConvertible) {
        self.baseURL = baseURL
    }
    
    lazy var decoder = JSONDecoder()
    
    @Sendable func request(_ requestData: RequestData) async throws -> (Data, URLResponse) {
        @Dependency(\.urlSession) var urlSession
        
        let request = try requestData.urlRequest(given: self.baseURL)
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RestClientError.apiError
        }
        return (data, response)
    }
}

extension RestClient {
    func request<T: Decodable>(_ requestData: RequestData) async throws -> T {
        let (data, _) = try await self.request(requestData)
        return try self.decoder.decode(T.self, from: data)
    }
}

enum RestClientError: Error {
    case apiError
}
