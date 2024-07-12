import Foundation
import XCTest
@testable import APIClient
import Models

final class APIModelTests: XCTestCase {
    func testCanCreateQuestionFromAPIModel() {
        let apiModel = QuestionAPIModel(id: 1, question: "some Question")
        
        let question = Models.Question(question: apiModel)
        let expectedQuestion = Models.Question(id: 1, question: "some Question")
        
        XCTAssertEqual(question, expectedQuestion)
    }
}
