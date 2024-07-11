import Foundation
import ComposableArchitecture
import SwiftUI

public struct QuestionFeedView: View {
    public var store: StoreOf<QuestionFeed>
    
    public init(store: StoreOf<QuestionFeed>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Question Feed View")
    }
}
