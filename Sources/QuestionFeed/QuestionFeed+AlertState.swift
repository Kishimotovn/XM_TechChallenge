import Foundation
import ComposableArchitecture
import Models

extension AlertState {
    static func submitFailure(_ errorMessage: String) -> AlertState<QuestionFeed.Action.Alert> {
        .init {
            TextState("Failed to submit answer.")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("Cancel")
            }
            ButtonState(action: .retry) {
                TextState("Retry")
            }
        } message: {
            TextState(errorMessage)
        }
    }
    
    static func submitSuccess() -> AlertState<QuestionFeed.Action.Alert> {
        .init {
            TextState("Submitted answer successfully.")
        } actions: {
            ButtonState {
                TextState("Ok")
            }
        }
    }
}
