import Foundation
import Models

typealias GetQuestionsOutput = [QuestionAPIModel]

struct QuestionAPIModel: Decodable {
    let id: Int
    let question: String
}

extension Models.Question {
    init(question: QuestionAPIModel) {
        self.init(id: question.id, question: question.question)
    }
}
