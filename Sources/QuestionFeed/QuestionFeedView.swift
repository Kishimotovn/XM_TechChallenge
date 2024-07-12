import Foundation
import ComposableArchitecture
import SwiftUI

@ViewAction(for: QuestionFeed.self)
public struct QuestionFeedView: View {
    @Bindable
    public var store: StoreOf<QuestionFeed>
    
    public init(store: StoreOf<QuestionFeed>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Questions submitted: \(store.submittedQuestions.count)")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            Form {
                LabeledContent("Question", value: store.currentQuestion?.question ?? "N/A")
                TextField(
                    "Answer",
                    text: .init(
                        get: { store.answer },
                        set: { send(.setAnswer(answer: $0)) }
                    )
                )
                Button {
                    send(.submitAnswerTapped)
                } label: {
                    if store.isQuestionubmitting {
                        ProgressView()
                    } else if store.isQuestionSubmitted {
                        Text("Question Submitted")
                    } else {
                        Text("Submit Answer")
                    }
                }.disabled(!store.canSubmitAnswer)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Question \(store.questionIndex + 1)/\(store.questions.count)")
        .toolbar {
            if store.questions.count > 1 {
                ToolbarItem {
                    Button {
                        send(.prevQuestionTapped)
                    } label: {
                        Text("Prev")
                    }.disabled(!store.canGoPrevQuestion)
                }
                ToolbarItem {
                    Button {
                        send(.nextQuestionTapped)
                    } label: {
                        Text("Next")
                    }.disabled(!store.canGoNextQuestion)
                }
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

#Preview {
    NavigationStack {
        QuestionFeedView(
            store: .init(
                initialState: QuestionFeed.State(questions: [
                    .init(id: 1, question: "question 1"),
                    .init(id: 2, question: "question 2"),
                    .init(id: 3, question: "question 3")
                ]),
                reducer: QuestionFeed.init
            )
        )
    }
}
