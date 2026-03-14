//
//  DebtTrackerApp.swift
//  Dime
//
//  Created by Piyush Chaudhari on 10/03/2026.
//

import SwiftUI

@main
struct DebtTrackerApp: App {
    @State private var itemStore = ItemStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(itemStore)
        }
    }
}
