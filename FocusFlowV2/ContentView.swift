//
//  ContentView.swift
//  FocusFlowV2
//
//  Created by Michael Isbell on 4/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab)
                .tabItem { Label("Now", systemImage: "circle.fill") }
                .tag(0)
            LaterView()
                .tabItem { Label("Later", systemImage: "list.bullet") }
                .tag(1)
            AddView(selectedTab: $selectedTab)
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
