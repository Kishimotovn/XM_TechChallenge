import Foundation
import ComposableArchitecture
import Models
import APIClient
import Utils
import OrderedCollections

@Reducer
public struct QuestionFeed {
    @ObservableState
    public struct State: Equatable {
        var questionIndex: Int = 0
        var questions: [Question]
        var answers: [Int: String] = [:]
        var submittingQuestions: Set<Int> = .init()
        var submittedQuestions: Set<Int> = .init()
        @Presents var alert: AlertState<Action.Alert>?

        var canGoPrevQuestion: Bool { questionIndex > 0 && !isQuestionubmitting }
        var canGoNextQuestion: Bool { questionIndex < questions.count - 1 && !isQuestionubmitting }
        var currentQuestion: Question? { self.questions.get(at: questionIndex) }
        var answer: String { self.answers[questionIndex] ?? "" }
        var isQuestionubmitting: Bool { self.submittingQuestions.contains(questionIndex) }
        var isQuestionSubmitted: Bool { self.submittedQuestions.contains(questionIndex) }
        var canSubmitAnswer: Bool { !isQuestionubmitting && !isQuestionSubmitted && !answer.isEmpty }

        public init(
            questions: [Question],
            questionIndex: Int = 0,
            answers: [Int: String] = [:],
            submittingQuestions: Set<Int> = .init(),
            submittedQuestions: Set<Int> = .init(),
            alert: AlertState<Action.Alert>? = nil
        ) {
            precondition(!questions.isEmpty)
            self.questions = questions
            self.questionIndex = questionIndex
            self.answers = answers
            self.submittingQuestions = submittingQuestions
            self.submittedQuestions = submittedQuestions
            self.alert = alert
        }
    }

    public enum Action: ViewAction, BindableAction {
        case view(ViewAction)
        case binding(BindingAction<State>)
        case submittingQuestion(questionIndex: Int)
        case questionSubmissionSuccess(questionIndex: Int)
        case questionSubmissionFailure(questionIndex: Int, questionID: Int, Error)
        case alert(PresentationAction<Alert>)
        
        public enum Alert: Equatable {
            case dismiss
            case retry
        }

        @CasePathable public enum ViewAction {
            case nextQuestionTapped
            case prevQuestionTapped
            case setAnswer(answer: String)
            case submitAnswerTapped
        }
    }
    
    public init() { }

    @Dependency(APIClient.self) var apiClient

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .view(.prevQuestionTapped):
                guard state.canGoPrevQuestion else { return .none }
                state.questionIndex -= 1
                return .none
            case .view(.nextQuestionTapped):
                guard state.canGoNextQuestion else { return .none }
                state.questionIndex += 1
                return .none
            case .view(.setAnswer(let answer)):
                state.answers[state.questionIndex] = answer
                return .none
            case .view(.submitAnswerTapped):
                guard state.canSubmitAnswer else { return .none }
                guard let currentQuestion = state.currentQuestion else { return .none }
                let currentQuestionID = currentQuestion.id
                let questionIndex = state.questionIndex
                let answer = state.answers[questionIndex] ?? ""
                return .run { [currentQuestionID, answer, questionIndex] send in
                    await send(.submittingQuestion(questionIndex: questionIndex))
                    try await apiClient.submitQuestion(id: currentQuestionID, answer: answer)
                    await send(.questionSubmissionSuccess(questionIndex: questionIndex))
                } catch: { [questionIndex, currentQuestionID] error, send in
                    await send(.questionSubmissionFailure(questionIndex: questionIndex, questionID: currentQuestionID, error))
                }
            case .submittingQuestion(let questionIndex):
                state.submittingQuestions.insert(questionIndex)
                return .none
            case .questionSubmissionSuccess(let questionIndex):
                state.submittingQuestions.remove(questionIndex)
                state.submittedQuestions.insert(questionIndex)
                state.alert = .submitSuccess()
                return .none
            case .questionSubmissionFailure(let questionIndex, let questionID, let error):
                state.submittingQuestions.remove(questionIndex)
                state.alert = .submitFailure("\(error.localizedDescription) (Question ID \(questionID))")
                return .none
            case .alert(.presented(.retry)):
                return .send(.view(.submitAnswerTapped))
            case .binding, .alert:
                return .none
            }
        }.ifLet(\.$alert, action: \.alert)
    }
}
