import Foundation
import SwiftUI
import ComposableArchitecture

public struct AppRootView: View {
    let store: StoreOf<AppRoot>
    
    public init(store: StoreOf<AppRoot>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
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
