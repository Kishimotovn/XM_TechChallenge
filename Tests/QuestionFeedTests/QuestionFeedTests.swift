import XCTest
import ComposableArchitecture
@testable import QuestionFeed
import APIClient
import Models

final class QuestionFeedTests: XCTestCase {
    @MainActor
    func testStateInit() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(questions: questions),
            reducer: QuestionFeed.init
        )
        
        store.assert {
            $0.questions = questions
            $0.questionIndex = 0
            $0.answers = [:]
            $0.submittedQuestions = .init()
            $0.submittingQuestions = .init()
            $0.alert = nil
        }
    }
    
    @MainActor
    func testOnPrevQuestionTappedShouldDecreaseQuestionIndexIfPossible() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 1
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.prevQuestionTapped)) {
            $0.questionIndex = 0
        }
    }
    
    @MainActor
    func testOnPrevQuestionTappedShouldNotDecreaseQuestionIndexIfNotPossible() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.prevQuestionTapped))
    }
    
    @MainActor
    func testOnNextQuestionTappedShouldIncreaseQuestionIndexIfPossible() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.nextQuestionTapped)) {
            $0.questionIndex = 1
        }
    }
    
    @MainActor
    func testOnNextQuestionTappedShouldNotIncreaseQuestionIndexIfNotPossible() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 1
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.nextQuestionTapped))
    }
    
    @MainActor
    func testOnSettingAnswerToSpecificQuestion() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                answers: [:]
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.setAnswer(answer: "some Answer"))) {
            $0.answers = [0: "some Answer"]
        }
    }
    
    @MainActor
    func testSubmittAnswerSuccess() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0,
                answers: [0: "some Answer"],
                submittingQuestions: .init(), 
                submittedQuestions: .init()
            ),
            reducer: QuestionFeed.init
        ) {
            $0[APIClient.self].overrideSubmitQuestion(questionID: 1, answer: "some Answer", throwing: nil)
        }

        await store.send(.view(.submitAnswerTapped))
        
        await store.receive(\.submittingQuestion, 0) {
            $0.submittingQuestions = .init([0])
        }
        await store.receive(\.questionSubmissionSuccess, 0) {
            $0.submittingQuestions = .init()
            $0.submittedQuestions = .init([0])
            $0.alert = .submitSuccess()
        }
    }
    
    @MainActor
    func testSubmittAnswerFailureBecauseAlreadySubmitting() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0,
                answers: [0: "some Answer"],
                submittingQuestions: .init([0]),
                submittedQuestions: .init()
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.submitAnswerTapped))
    }
    
    @MainActor
    func testSubmittAnswerFailureBecauseAlreadySubmitted() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0,
                answers: [0: "some Answer"],
                submittingQuestions: .init(),
                submittedQuestions: .init([0])
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.submitAnswerTapped))
    }
    
    @MainActor
    func testSubmittAnswerFailureBecauseNoAnswer() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0,
                answers: [:],
                submittingQuestions: .init(),
                submittedQuestions: .init()
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.submitAnswerTapped))
    }
    
    @MainActor
    func testSubmittAnswerFailureBecauseEmptyAnswer() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0,
                answers: [0: ""],
                submittingQuestions: .init(),
                submittedQuestions: .init()
            ),
            reducer: QuestionFeed.init
        )
        
        await store.send(.view(.submitAnswerTapped))
    }
    
    struct TestError: Error, LocalizedError {
        var errorDescription: String? { return "Test Error" }
    }
    
    @MainActor
    func testSubmittAnswerFailureBecauseAPIError() async throws {
        let error = TestError()
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0,
                answers: [0: "some Answer"],
                submittingQuestions: .init(),
                submittedQuestions: .init()
            ),
            reducer: QuestionFeed.init
        ) {
            $0[APIClient.self].overrideSubmitQuestion(questionID: 1, answer: "some Answer", throwing: error)
        }
        
        await store.send(.view(.submitAnswerTapped))
        
        await store.receive(\.submittingQuestion, 0) {
            $0.submittingQuestions = .init([0])
        }
        await store.receive(\.questionSubmissionFailure) {
            $0.submittingQuestions = .init()
            $0.alert = .submitFailure("Test Error (Question ID \(1))")
        }
    }
    
    @MainActor
    func testRetrySubmittingQuestion() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2")
        ]
        let store = TestStore(
            initialState: QuestionFeed.State(
                questions: questions,
                questionIndex: 0,
                answers: [0: "some Answer"],
                submittingQuestions: .init(),
                submittedQuestions: .init(),
                alert: .submitFailure("Test Error (Question ID \(1))")
            ),
            reducer: QuestionFeed.init
        ) {
            $0[APIClient.self].overrideSubmitQuestion(questionID: 1, answer: "some Answer", throwing: nil)
        }
    
        await store.send(.alert(.presented(.retry))) {
            $0.alert = nil
        }
        
        await store.receive(\.view.submitAnswerTapped)
        
        await store.receive(\.submittingQuestion, 0) {
            $0.submittingQuestions = .init([0])
        }
        await store.receive(\.questionSubmissionSuccess, 0) {
            $0.submittingQuestions = .init()
            $0.submittedQuestions = .init([0])
            $0.alert = .submitSuccess()
        }
    }
}
