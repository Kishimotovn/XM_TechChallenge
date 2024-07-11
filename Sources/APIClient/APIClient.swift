import Foundation
import ComposableArchitecture
import Models

@DependencyClient
public struct APIClient {
    public var getQuestions: @Sendable () async throws -> [Question]
    public var submitQuestion: @Sendable (_ id: Int, _ answer: String) async throws -> Void
}

extension APIClient: DependencyKey {
    public static var testValue: APIClient = .init()
    public static var previewValue: APIClient = .init {
        [
            .init(id: 1, question: "What is your favorite colour?"),
            .init(id: 2, question: "What is your favourite food?")
        ]
    } submitQuestion: { id, answer in
        
    }

    
    public static var liveValue: APIClient = .live
}

#if DEBUG
import XCTestDebugSupport

extension APIClient {
    public mutating func overrideGetQuestions(
        with questions: [Question],
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "getQuestionsAPI Called")
        self.getQuestions = {
            fulfill()
            if let error {
                throw error
            }
            return questions
        }
    }
    
    public mutating func overrideSubmitQuestion(
        questionID: Int,
        answer: String,
        throwing error: Error? = nil
    ) {
        self.submitQuestion = { @Sendable [self] requestQuestionID, requestAnswer in
            guard
                requestQuestionID == questionID,
                requestAnswer == answer
            else {
                return try await self.submitQuestion(requestQuestionID, requestAnswer)
            }
            if let error {
                throw error
            }
        }
    }
}
#endif
