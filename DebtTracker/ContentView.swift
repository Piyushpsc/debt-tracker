//
//  ContentView.swift
//  Dime
//
//  Created by Piyush Chaudhari on 10/03/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(ItemStore.self) private var store
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        TabView {
            InProcessView()
                .environment(store)
                .tabItem {
                    Label("Debt", systemImage: "arrow.triangle.2.circlepath")
                }
            PaidView()
                .environment(store)
                .tabItem {
                    Label("Paid", systemImage: "checkmark.circle")
                }
            SettingsView()
                .environment(store)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .preferredColorScheme(appSettings.resolvedColorScheme)
    }
}

#Preview {
    ContentView()
        .environment(ItemStore())
        .environment(AppSettings())
}
