import XCTest
import ComposableArchitecture
@testable import AppRoot
import QuestionFeed
import APIClient
import Models

final class AppRootTests: XCTestCase {
    @MainActor
    func testStateInit() async throws {
        let store = TestStore(
            initialState: AppRoot.State(),
            reducer: AppRoot.init
        )
        
        store.assert {
            $0.isLoading = false
            $0.errorMessage = nil
        }
    }

    @MainActor
    func testGetQuestionnaireSuccess() async throws {
        let questions: [Question] = [
            .init(id: 1, question: "question1"),
            .init(id: 2, question: "question2")
        ]
        let store = TestStore(
            initialState: AppRoot.State(),
            reducer: AppRoot.init
        ) {
            $0[APIClient.self].overrideGetQuestions(
                with: questions,
                throwing: nil
            )
        }
        
        await store.send(.view(.startQuestionnaireTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
        
        await store.receive(\.questionsUpdated, questions) {
            $0.path[id: 0] = .init(questions: questions)
        }
    }
    
    @MainActor
    func testGetQuestionnaireSuccessButNoQuestionReturned() async throws {
        let questions: [Question] = []
        let store = TestStore(
            initialState: AppRoot.State(),
            reducer: AppRoot.init
        ) {
            $0[APIClient.self].overrideGetQuestions(
                with: questions,
                throwing: nil
            )
        }
        
        await store.send(.view(.startQuestionnaireTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
        
        await store.receive(\.questionsUpdated, questions)
    }
    
    @MainActor
    func testGetQuestionnaireFailure() async throws {
        let error = NSError(domain: "task", code: 1)
        let store = TestStore(
            initialState: AppRoot.State(),
            reducer: AppRoot.init
        ) {
            $0[APIClient.self].overrideGetQuestions(
                with: [],
                throwing: error as Error
            )
        }
        
        await store.send(.view(.startQuestionnaireTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(\.errorMessageUpdated) {
            $0.errorMessage = error.localizedDescription
        }
        
        await store.receive(\.isLoadingUpdated, false) {
            $0.isLoading = false
        }
    }
}
