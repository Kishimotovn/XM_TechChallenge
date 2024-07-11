import XCTest
import Foundation
import SnapshotTesting
@testable import AppRoot
import ComposableArchitecture
import SwiftUI

final class DataLoadViewTests: XCTestCase {
    func testSnapshotInit() {
        let state = AppRoot.State(isLoading: false, errorMessage: nil)
        let store = StoreOf<AppRoot>(initialState: state, reducer: AppRoot.init)
        let view = AppRootView(store: store)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSnapshotLoading() {
        let state = AppRoot.State(isLoading: true)
        let store = StoreOf<AppRoot>(initialState: state, reducer: AppRoot.init)
        let view = AppRootView(store: store)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
    
    func testSnapshotErrorMessage() {
        let state = AppRoot.State(errorMessage: "Some Error Message")
        let store = StoreOf<AppRoot>(initialState: state, reducer: AppRoot.init)
        let view = AppRootView(store: store)
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image)
    }
}
