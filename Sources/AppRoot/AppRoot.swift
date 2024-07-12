import Foundation
import ComposableArchitecture
import QuestionFeed
import APIClient
import Models

@Reducer
public struct AppRoot {
    @ObservableState
    public struct State: Equatable {
        var errorMessage: String?
        var isLoading: Bool = false
        var path: StackState<QuestionFeed.State> = .init()
        
        public init(isLoading: Bool = false, errorMessage: String? = nil) {
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }
    }
    
    public enum Action: ViewAction {
        case view(ViewAction)
        case path(StackAction<QuestionFeed.State, QuestionFeed.Action>)
        case isLoadingUpdated(Bool)
        case errorMessageUpdated(String)
        case questionsUpdated([Question])

        @CasePathable public enum ViewAction {
            case startQuestionnaireTapped
        }
    }

    public init() { }

    @Dependency(APIClient.self) var apiClient

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .view(.startQuestionnaireTapped):
                state.isLoading = true
                return .run { send in
                    let questions = try await apiClient.getQuestions()
                    await send(.isLoadingUpdated(false))
                    await send(.questionsUpdated(questions))
                } catch: { error, send in
                    await send(.errorMessageUpdated(error.localizedDescription))
                    await send(.isLoadingUpdated(false))
                }
            case .isLoadingUpdated(let isLoading):
                state.isLoading = isLoading
                return .none
            case .errorMessageUpdated(let errorMessage):
                state.errorMessage = errorMessage
                return .none
            case .questionsUpdated(let questions):
                state.path.append(.init(questions: questions))
                return .none
            case .path:
                return .none
            }
        }.forEach(\.path, action: \.path) {
            QuestionFeed()
        }
    }
}
