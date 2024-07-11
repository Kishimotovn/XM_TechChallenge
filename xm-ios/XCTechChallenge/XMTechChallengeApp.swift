//
//  XMTechChallengeApp.swift
//  XMTechChallenge
//
//  Created by Phan Anh Tran on 11/07/2024.
//

import SwiftUI
import AppRoot
import ComposableArchitecture

@main
struct XMTechChallengeApp: App {
    let store: StoreOf<AppRoot>
    
    init() {
        self.store = .init(initialState: AppRoot.State()) {
            AppRoot()._printChanges(.actionLabels)
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(store: self.store)
        }
    }
}
