import Foundation
import SwiftUI
import ComposableArchitecture
import QuestionFeed

@ViewAction(for: AppRoot.self)
public struct AppRootView: View {
    @Bindable
    public var store: StoreOf<AppRoot>
    
    public init(store: StoreOf<AppRoot>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            VStack(spacing: 16) {
                if let errorMessage = store.errorMessage {
                    Text("Error: \(errorMessage)")
                }
                Button {
                    send(.startQuestionnaireTapped)
                } label: {
                    if store.isLoading {
                        ProgressView()
                    } else {
                        Text("Start survey")
                    }
                }.disabled(store.isLoading)
                .buttonStyle(.bordered)
            }
            .navigationTitle("Welcome")
            .frame(maxWidth: .greatestFiniteMagnitude)
        } destination: { store in
            QuestionFeedView(store: store)
        }
    }
}

#Preview {
    AppRootView(
        store: .init(
            initialState: AppRoot.State(),
            reducer: AppRoot.init
        )
    )
}
