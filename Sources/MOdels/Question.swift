import Foundation

public struct Question: Identifiable, Sendable {
    public let id: Int
    public let question: String

    public init(id: Int, question: String) {
        self.id = id
        self.question = question
    }
}

extension Question: Equatable { }
