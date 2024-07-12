import XCTest
import Foundation
import SnapshotTesting
@testable import QuestionFeed
import ComposableArchitecture
import APIClient
import Models
import UIKit
import SwiftUI

final class QuestionFeedViewTests: XCTestCase {
    func testSnapshotFeedNormal() {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2"),
            .init(id: 3, question: "question 3"),
            .init(id: 4, question: "question 4")
        ]
        let state = QuestionFeed.State(
            questions: questions
        )
        let store = StoreOf<QuestionFeed>(initialState: state, reducer: QuestionFeed.init)
        let view = QuestionFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testNextButtonDisabled() {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "question 2"),
            .init(id: 3, question: "question 3"),
            .init(id: 4, question: "question 4")
        ]
        let state = QuestionFeed.State(
            questions: questions,
            questionIndex: 3
        )
        let store = StoreOf<QuestionFeed>(initialState: state, reducer: QuestionFeed.init)
        let view = QuestionFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testLongQuestionWithAnswer() {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "This is a ver long question that might get to the 2nd line, lorem ipsum"),
            .init(id: 3, question: "question 3"),
            .init(id: 4, question: "question 4")
        ]
        let state = QuestionFeed.State(
            questions: questions,
            questionIndex: 1,
            answers: [1: "some Answer"]
        )
        let store = StoreOf<QuestionFeed>(initialState: state, reducer: QuestionFeed.init)
        let view = QuestionFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSubmittedQuestion() {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "This is a ver long question that might get to the 2nd line, lorem ipsum"),
            .init(id: 3, question: "question 3"),
            .init(id: 4, question: "question 4")
        ]
        let state = QuestionFeed.State(
            questions: questions,
            questionIndex: 1,
            answers: [1: "some Answer"],
            submittedQuestions: [1]
        )
        let store = StoreOf<QuestionFeed>(initialState: state, reducer: QuestionFeed.init)
        let view = QuestionFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSubmittingQuestion() {
        let questions: [Question] = [
            .init(id: 1, question: "question 1"),
            .init(id: 2, question: "This is a ver long question that might get to the 2nd line, lorem ipsum"),
            .init(id: 3, question: "question 3"),
            .init(id: 4, question: "question 4")
        ]
        let state = QuestionFeed.State(
            questions: questions,
            questionIndex: 1,
            answers: [1: "some Answer"],
            submittingQuestions: [1],
            submittedQuestions: []
        )
        let store = StoreOf<QuestionFeed>(initialState: state, reducer: QuestionFeed.init)
        let view = QuestionFeedView(store: store)
        let vc = UINavigationController(rootViewController: UIHostingController(rootView: view))
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
}
